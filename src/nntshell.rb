#! ruby -E Windows-31J:utf-8
require "./shellbase"
require "./nntalk"

class NNTShell < ShellBase
	
	#
	def initialize
		super(ShellBase::Command.new('終了', nil, '対話を終了する'))
		#Encoding.default_external = Encoding.find('windows-31J')
		#Encoding.default_internal = Encoding.find('utf-8')
		
		regist_command
		@nntalk = NNTalk.new
	end
	
	#
	def regist_command
		add_command('評価せよ',
								lambda{|argv| @nntalk.recognize(argv[1])},
								'文字列を評価させる')
		add_command('これが正解',
								lambda{|argv| @nntalk.teach_correct(argv[1])},
								'正解を教える')
		add_command('これは間違い',
								lambda{|argv| @nntalk.teach_wrong(argv[1])},
								'間違いを教える')
		add_command('単語一覧',
								lambda{|argv| @nntalk.list_word()},
								'記憶されている単語の一覧を表示する。')
		add_command('単語調査',
								lambda{|argv| @nntalk.inspect(argv[1])},
								'特定のニューロンの詳細を表示する。')
		add_command('記憶復元',
								lambda{|argv| @nntalk.load('nntalk.txt')},
		            'ニューロンの記憶情報を復元する。')
		add_command('記憶保存',
								lambda{|argv| @nntalk.save('nntalk.txt')},
		            'ニューロンの記憶情報を保存する')
	end

end

if $0 == __FILE__ then
	nnt = NNTShell.new
	nnt.interaction
end