# ニューロンクラス 
#
class Neuron
	# クラス変数
	#
	@@all_neurons = []	# 生成順の全ニューロン
	@@neuron_dic  = {}	# 名称から特定するための辞書
	
	# シナプス結合クラス
	#
	class Synapse

		@@strength_init   = 1.0
		@@strength_factor = 0.5

		# Synapse コンストラクタ
		# @param neuron_or_index	[Neuron|Integer]
		# @param strength					[Float]
		def initialize(neuron_or_index, strength = nil)
			@neuron   = nil
			@strength = strength || @@strength_init

			case neuron_or_index
			when Neuron
				@neuron = neuron_or_index
				@index  = @neuron.index
			when Integer
				@index  = neuron_or_index
				@neuron = Neuron.get_at(@index)
			end
		end
		
		attr_reader(:neuron, :index, :strength)

		# シナプス入力値を取得
		def in_value
			@neuron = Neuron.get_at(@index) if @neuron.nil?
			@neuron.out_value * @strength
		end 

		# 結合強度を強化
		def strengthen
			if @neuron.out_value > 0.0 then
				@strength *= (1.0 + @@strength_factor)
				# @strength  = 1.0 if @strength > 1.0
				@neuron.strengthen
			end 
		end

		# 結合強度を弱化
		def weaken
			if @neuron.out_value > 0.0 then
				@strength *= (1.0 - @@strength_factor)
				# @strength  = @@strength_init if @strength < @@strength_init
				@neuron.weaken
			end
		end 

	end
	
	
	# Newron コンストラクタ
	#
	def initialize(name = nil)
		@index     = @@all_neurons.size
		@name      = name || @index.to_s
		@synapse   = []
		@out_value = 0
		
		@@all_neurons << self
		@@neuron_dic[@name] = self
	end
	
	attr_reader(:index, :name, :synapse)
	
	# 入力値の合計値
	# @return				[Float]
	def in_value
		ret = 0.0
		@synapse.each {|syn| ret += syn.in_value}
		return ret
	end
	
	# 出力値の取得
	# @return				[Float]
	def out_value
		if @synapse.size > 0 then
			@out_value = (self.in_value >= @synapse.size / 2.0 ? 1.0 : 0.0)
		end
		return @out_value
	end

	# 出力値の設定
	#		シナプス結合が無い場合にのみ設定可能。
	# @value				[Integer]
	def out_value=(value)
		if @synapse.size <= 0 then
			@out_value = (value > 0) ? 1.0 : 0.0
		end
	end
	
	# 他のニューロンとの結合
	# @param neuron_or_index	[Neuron|Integer]
	# @param strength					[Float]
	def connect(neuron_or_index, strength = nil)
		@synapse << Synapse.new(neuron_or_index, strength)
	end
	
	# 接続強度の強化
	# @param reconnect				[Neuron[]]
	def strengthen(reconnect = nil)
		@synapse.each {|syn| syn.strengthen}
		
		# 強化すべき結合がなかったら、出力のあるニューロンに接続
		reconnect.each do |neu|
			self.connect(neu) if neu.out_value > 0.0
		end
	end
	
	# 接続強度の弱化
	def weaken
		@synapse.each {|syn| syn.weaken}

		# 接続強度が一定値を下回ったら、接続解除
		disconnect = []
		@synapse.each do |syn|
			disconnect << syn if syn.strength < (@@strength_init / 10.0)
		end
		@synapse - disconnect
	end
	
	# 自身の情報を表示
	def inspect
		puts " Name: #{@name}"
		puts "Value: #{@out_value}"
		puts "Synapse:"
		@synapse.each do |syn|
			neu_name = syn.neuron.nil? ? 'nil' : syn.neuron.name
			printf("  %8.5f <- %s\n", syn.strength, neu_name)
		end
	end
	
	# インデックスから対応するニューロンを取得
	# @param index_or_name	[Integer|String]
	def self.get_at(index_or_name)
		case index_or_name
		when Integer
			index = index_or_name
			return nil if index >= @@all_neurons.size
			return @@all_neurons[index]
		when String
			name  = index_or_name
			return nil unless @@neuron_dic.include?(name)
			return @@neuron_dic[name]
		end
	end

	# ニューロン情報をファイルに保存
	def self.save(fname)
		File.open(fname, "o") do |f|
			save_to(f)
		end
	end
	
	def self.save_to(file)
		0.upto(@all_neurons.size - 1) {|idx|
			neu = @all_neurons[idx]
			neu_info = "#{idx} #{neu.name}"
			neu.synapse.each {|syn|
				neu_info << " #{syn.index}:#{syn.strength}"
			}
			puts neu_info
			file.puts neu_info
		}
end
	
	# ニューロン情報をファイルから復元
	def self.load(fname)
		File.open(fname, "r") do |f|
			load_from(f)
		end
	end
	
	def self.load_from(file)
		while data = f.gets.chomp
			params = data.split(' ')
			neu = self.new(params[1])
			if params.size > 2 then
				params[2 .. -1].each {|syn_info|
					syn_param = syn_info.split(':')
					neu.connect(syn_param[0].to_i, syn_param[1].to_f)
				}
			end
		end
	end
end