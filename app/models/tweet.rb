# coding: utf-8
class Tweet
  attr_accessor :post

  #-----------------------#
  # self.set_search_param #
  #-----------------------#
  def self.set_search_param( args )
    search_param = ""
    search_param += "?q=#{CGI.escape( args[:q] + ' -RT' )}"
    search_param += "&locale=ja"
    search_param += "&lang=ja"
    search_param += "&rpp=#{args[:rpp]}"
    search_param += "&page=#{args[:page]}"
    search_param += "&show_user=false"
    search_param += "&result_type=recent"

    return search_param
  end

end
