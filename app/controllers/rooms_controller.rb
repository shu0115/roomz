# coding: utf-8
class RoomsController < ApplicationController
  before_filter :login_authorize, :except => [ :index ]

  $per_page = 30

  #-------#
  # index #
  #-------#
  def index
    if session[:user_id].present? and session[:access_url].present?
      redirect_to session[:access_url]
      session[:access_url] = nil
      return
    end
    
    @rooms = Room.all( :include => :user )
  end

  #-----#
  # new #
  #-----#
  def new
    @room = Room.new( :hash_tag => "#")
    
    @submit = "create"
  end

  #------#
  # edit #
  #------#
  def edit
    @room = Room.where( :id => params[:id] ).first
    redirect_to :action => "index" and return if @room.blank?

    @submit = "update"
  end

  #--------#
  # create #
  #--------#
  def create
    @room = Room.new( params[:room] )
    @room.user_id = session[:user_id]

    if @room.save
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  #--------#
  # update #
  #--------#
  def update
    @room = Room.where( :id => params[:id] ).first
    redirect_to :action => "index" and return if @room.blank?

    if @room.update_attributes( params[:room] )
      redirect_to :action => "index"
    else
      flash[:notice] = "ルームの更新に失敗しました。"
      @submit = "update"
      render :action => "edit"
    end
  end

  #---------#
  # destroy #
  #---------#
  def destroy
    @room = Room.where( :id => params[:id] ).first
    redirect_to :action => "index" and return if @room.blank?

    @room.destroy

    redirect_to :action => "index"
  end

  #------#
  # show #
  #------#
  def show
    @room = Room.where( :id => params[:id] ).first( :include => "user" )
    redirect_to :action => "index" and return if @room.blank?
    
    params[:tweet_page] = 1 if params[:tweet_page].blank? or params[:tweet_page].to_i <= 0
    params[:tweet_page] = ( 1500 / $per_page ) if !params[:tweet_page].blank? and params[:tweet_page].to_i >= ( 1500 / $per_page )
    search_param = Tweet.set_search_param( :q => @room.hash_tag, :rpp => $per_page, :page => params[:tweet_page] )
    @twitter_get = current_user.twitter.get( "http://search.twitter.com/search.json#{search_param}" )
  end
  
  #------#
  # post #
  #------#
  def post
    @room = Room.where( :id => params[:id] ).first
    redirect_to :action => "index" and return if @room.blank?

    post_tweet = "#{params[:tweet][:post].presence} #{@room.hash_tag}"

    # Twitter投稿
    begin
      if current_user.twitter.post( '/statuses/update.json', :status => post_tweet )
        flash[:tweet_notice] = "<p style=\"color: green\">Twitterへの投稿が完了しました。</p>"
      else
        flash[:tweet_notice] = "<p style=\"color: red;\">Twitterへの投稿に失敗しました。</p>"
      end
    rescue => exc
      flash[:tweet_notice] = "<p style=\"color: red;\">#{exc}</p>"
    end
    
    redirect_to :action => "show", :id => params[:id] and return
  end
  
  #------------#
  # char_count #
  #------------#
  def char_count
    render :text => ( 140 - 1 - params[:value].length - params[:hash_tag_length].to_i )
  end

  private
  
  #-----------------#
  # login_authorize #
  #-----------------#
  def login_authorize
    if session[:user_id].blank?
      session[:access_url] = request.url
      flash[:notice] = "ログインして下さい。"
      redirect_to :action => "index" and return
    end
  end

end
