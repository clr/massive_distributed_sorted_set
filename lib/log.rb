# Log messages to a common location.
class Log
  def initialize(message)
    @message = message
  end

  # Write the log file.
  def write
    File.open(File.join(ROOT_DIR,'log','notice.log'),'w'){|f| f.write @message}
  end
end
