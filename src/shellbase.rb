require "kconv"

# コマンドライン処理のフレームワーク
#
class ShellBase
	# コンストラクタ
	#
	def initialize(exit_cmd = nil)
		@prompt = '> '
		@exit_cmd = exit_cmd || Command.new('exit', nil, 'exit this shell.')
		CommandDict.add(@exit_cmd)
		CommandDict.add('help', lambda{|argv| CommandDict.usage},
														'display this usage list.')
	end
	
	# コマンド追加
	#
	def add_command(cmd_or_name, proc = nil, usage = nil)
		CommandDict.add(cmd_or_name, proc, usage)
	end
	
	# 対話処理
	#
	def interaction
		while true
			print @prompt
			cmdargv = (gets.chomp!).split(' ')
			
			cmd = CommandDict.get(cmdargv[0])
			if cmd.nil? then
				puts "'#{cmdargv[0]}' is ivalid commnad"
				next
			end
			
			if cmd == @exit_cmd then
				break
			else
				cmd.exec(cmdargv)
			end
		end
	end
	
	# コマンド辞書
	#
	class CommandDict
		@@cmd_dict = {}

		def self.usage
			keys = @@cmd_dict.keys.sort
			keys.each {|name| printf("%-20s %s\n",
												       name, @@cmd_dict[name].usage)}
		end
		
		# コマンド追加
		#
		def self.add(cmd_or_name, proc = nil, usage = nil)
			case cmd_or_name
			when Command
				# puts "add by Command [#{cmd_or_name.name}]"
				@@cmd_dict[cmd_or_name.name] = cmd_or_name
			when String
				# puts "add by String [#{cmd_or_name}]"
				@@cmd_dict[cmd_or_name] = Command.new(cmd_or_name, proc, usage)
			end
		end
		
		# コマンド取得
		#
		def self.get(name)
			return nil unless @@cmd_dict.include?(name)
			@@cmd_dict[name]
		end
	end
	
	# コマンドクラス
	#
	class Command
		# コンストラクタ
		#
		def initialize(name, proc = nil, usage = nil)
			@name  = name		# コマンド名
			@proc  = proc		# コマンドの処理 lambda{|argv| ...}
			@usage = usage	# コマンドの説明
		end
		
		# メンバ参照
		attr_reader(:name, :proc, :usage)
		
		# コマンド名の比較
		#
		def ==(cmd)
			(cmd.name == @name)
		end
		
		# コマンドの実行
		# @param param	[String[]]	コマンド引数。0番目は自身のコマンド名
		def exec(param)
			if param === String then
				param = param.split(' ')
			end
			
			@proc.call(param)
		end
	end
end

# Test
if $0 == __FILE__ then
	class TestShell < ShellBase
		def initialize
			super
			
			CommandDict.add('echo', lambda{|argv| argv.each {|arg| print "#{arg} "}; puts},
			                        'echo command line')
		end
	end
	
	shell = TestShell.new
	cmd = ShellBase::Command.new('test', lambda{|argv| puts 'Test'}, 'test command')
	shell.add_command(cmd)
	shell.interaction
end