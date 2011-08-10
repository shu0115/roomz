# coding: utf-8
class Utility
  def self.replace_message( message )
    message.to_s.gsub!( "You have logged in successfully.", "ログインが完了しました。")
    
    return message
  end
end
