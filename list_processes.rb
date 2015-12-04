require 'terminal-table'
class ProcessInfo
  attr_accessor :exec_path, :name, :pid
  
  # Call wmic command to list running processes
  def self.parseWmic(cmd)
    result = `#{cmd}`
    raise("Error: " + result) unless $? == 0
    processes = []
    pinfo = nil
    result.split(/\r?\n/).each do |line|
      pinfo_hash = {}
      next if line =~ /^\s*$/
      if line =~ /ExecutablePath=(.*)/i
        pinfo = ProcessInfo.new
        pinfo.exec_path = $1
      elsif line =~ /Name=(.*)/i
        pinfo.name = $1
      elsif line =~ /ProcessId=(\d+)/i
        pinfo.pid = $1
        pinfo.pid.to_i == $$.to_i
        pinfo_hash['name'] = pinfo.name.to_s
        pinfo_hash['pid'] = pinfo.pid.to_s
        pinfo_hash['exec_path'] = pinfo.exec_path.to_s
        processes << pinfo_hash unless pinfo.pid.to_i == $$.to_i
      end
    end

    # Saving data into an array
    rows = []
    processes.each do |process|
      if process['exec_path'] != ''
        rows << [process['pid'], process['exec_path']]
      elsif 
        rows << [process['pid'], process['name']]
      end
    end

    # Writing array to text file
    table = Terminal::Table.new :title => "RUNNING PROCESSES", :headings => ['PID', 'Description'], :rows => rows
    file_name = 'process_log.txt'
    file = File.new(file_name, 'w')
    file.write(table)
    file.close
    %x{call #{file_name}}
  end
   
  def self.queryProcess(processName)
    puts "                                                                  "
    puts "                      LISTING PROCESSES                           "
    puts "                                                                  "
    puts "            developed by vcn - github.com/nhan712                 "
    puts "                                                                  "
    puts "=================================================================="

    return self.parseWmic("wmic process where \"name like '" + processName + 
                "%'\" get Name, ProcessId, ExecutablePath /format:list")
  end
end 
 
ProcessInfo.queryProcess('')