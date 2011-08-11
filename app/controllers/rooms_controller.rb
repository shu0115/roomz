# coding: utf-8
class RoomsController < ApplicationController
  
  $per_page = 30

  #-------#
  # index #
  #-------#
  def index
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
    if current_user.twitter.post( '/statuses/update.json', :status => post_tweet )
      flash[:tweet_notice] = "Twitterへの投稿が完了しました。"
    else
      flash[:tweet_notice] = "<span style=\"color: red;\">Twitterへの投稿に失敗しました。</span>"
    end
    
    redirect_to :action => "show", :id => params[:id] and return
  end
  
  #------------#
  # char_count #
  #------------#
  def char_count
    render :text => ( 140 - 1 - params[:value].split(//u).length - params[:hash_tag_length].to_i )
  end


end
