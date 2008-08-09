class MyMailer
  def self.receive(mail)
    puts "REC"
  end
  
  def self.deleteif(mail)
    puts "deleteif"
    return true
  end
end
