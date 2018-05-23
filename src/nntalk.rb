require "kconv"
require "./neuron"

# 言語認識クラス
#
class NNTalk
	
	# コンストラクタ
	def initialize
		@char_layer = []
		@word_layer = []
	end
	
	# 認識
	# @param str		[String]
	# @return				[Neuron]
	def recognize(str)
		# 文字層のクリア
		clear_char_layer
		
		# 入力層への値を設定
		(1 .. str.size).each do |n|
			char_name = "#{n}#{str[n - 1]}"
			neu = Neuron.get_at(char_name)
			neu = add_char(char_name) if neu.nil?
			neu.out_value = 1
		end
		
		# 単語層の認識処理
		res = []
		@word_layer.each do |word_name|
			wd_neu = Neuron.get_at(word_name)
			if wd_neu.out_value > 0 then
				res << word_name
			end
		end
		
		# 結果の出力
		if res.empty? then
			puts "わかりません。"
		else
			puts "#{res.join(' ')} ですか？"
		end
	end
	
	# 学習：正解強化
	# @param start		[String]
	def teach_correct(start)
		neu = Neuron.get_at(start)
		if neu.nil? then
			add_word(start)
			puts "単語を追加しました。"
		else
			neu.strengthen
			puts "正解を学習しました。"
		end
	end
	
	# 学習：間違い弱化
	def teach_wrong(start)
		neu = Neuron.get_at(start)
		if neu.nil? then
			puts "不明な単語です。"
		else
			neu.weaken
			puts "間違いを学習しました。"
		end
	end

	# 文字層の出力値クリア
	def clear_char_layer
		@char_layer.each do |char_name|
			neu = Neuron.get_at(char_name)
			neu.out_value = 0 unless neu.nil?
		end
	end

	# 文字層ニューロンの追加
	# @param char_name	[String]
	def add_char(char_name)
		ch_neu = Neuron.new(char_name)
		@char_layer << char_name
		
		@word_layer.each do |word_name|
			wd_neu = Neuron.get_at(word_name)
			wd_neu.connect(ch_neu) unless wd_neu.nil?
		end
		
		return ch_neu
	end
	
	# 単語層ニューロンの追加
	# @param word_name	[String]
	def add_word(word_name)
		wd_neu = Neuron.new(word_name)
		@word_layer << word_name
		
		@char_layer.each do |char_name|
			ch_neu = Neuron.get_at(char_name)
			wd_neu.connect(ch_neu) unless ch_neu.nil?
		end
		
		return wd_neu
	end
	
	# 
	# @param word		[String]
	# @return				[Neuron]
	def get_word(word)
		
	end
	
	# 登録単語の一覧
	# 
	def list_word()
		@word_layer.each {|word| puts word}
	end
	
	# ニューロンの詳細表示
	# @param name		[String]
	def inspect(name)
		neu = Neuron.get_at(name)
		unless neu.nil? then
			neu.inspect
		end
	end
	
	# ニューロン構成の保存
	# @param fname	[String]
	def save(fname)
		File.open(fname, "w") do |f|
			f.puts @char_layer.join(' ')
			f.puts @word_layer.join(' ')
			Neuron.save_to(f)
		end
	end
	
	# ニューロン構成の復元
	# @param fname	[String]
	def load(fname)
		File.open(fname, "r") do |f|
			@char_layer = f.gets.chomp.split(' ')
			@word_layer = f.gets.chomp.split(' ')
			Neuron.load_from(f)
		end
	end
	
end