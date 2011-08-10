# coding: utf-8
class RoomsController < ApplicationController
  
  $per_page = 30

  #-------#
  # index #
  #-------#
  def index
    @rooms = Room.all( :include => "user" )
  end

  #------#
  # show #
  #------#
  #  def show
  #  @room = Room.find( params[:id] )
  #end

  #-----#
  # new #
  #-----#
  def new
    @room = Room.new
    @room.hash_tag = @room.hash_tag.presence || "#"
    
    @submit = "create"
  end

  #------#
  # edit #
  #------#
  def edit
    @room = Room.find( params[:id] )

    @submit = "update"
  end

  #--------#
  # create #
  #--------#
  def create
    @room = Room.new( params[:room] )
    @room.user_id = session[:user_id]

    if @room.save
#      flash[:notice] = "Room was successfully created."
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  #--------#
  # update #
  #--------#
  def update
    @room = Room.find( params[:id] )

    if @room.update_attributes( params[:room] )
#      flash[:notice] = "Room was successfully updated."
#      redirect_to :action => "show", :id => params[:id]
      redirect_to :action => "index"
    else
      render :action => "edit", :id => params[:id]
    end
  end

  #---------#
  # destroy #
  #---------#
  def destroy
    @room = Room.find( params[:id] )
    @room.destroy

    redirect_to :action => "index"
  end



#----------

  #------#
  # show #
  #------#
  def show
    @room = Room.where( "id = ?", params[:id] ).first
#    @tweet = Tweet.new
#    @tweets = Tweet.paginate_by_args_option( { :room_id => params[:room_id] }, { :page => params[:page], :per_page => $per_page, :order => "created_at DESC", :include => [ "room", "user" ] }  )
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
#    @room = Room.find_by_args( :id => params[:room_id] )
    @room = Room.where( "id = ?", params[:id] ).first
    redirect_to :action => "index" and return if @room.blank?

    print "[ params[:tweet] ] : "; p params[:tweet] ;

#    @tweet = params[:tweet]
#    post_tweet = params[:tweet][:post].presence
    print "[ params[:tweet][:post].presence ] : "; p params[:tweet][:post].presence ;
#    @tweet.user_id = session[:user_id]
#    @tweet.room_id = @room.id
    post_tweet = "#{params[:tweet][:post].presence} #{@room.hash_tag}"

    # Twitter投稿
    #    if @room.synchro_flag == "ON"
      if current_user.twitter.post( '/statuses/update.json', :status => post_tweet )
        flash[:tweet_notice] = "Twitterへの投稿が完了しました。"
      else
        flash[:tweet_notice] = "<span style=\"color: red;\">Twitterへの投稿に失敗しました。</span>"
      end
    #end
    
    # DB保存
    #    if @room.keep_flag == "ON"
    #  unless @tweet.save
    #    flash[:tweet_notice] = "Tweetの保管に失敗しました。"
    #  end
    #end

    #if @room.synchro_flag == "OFF" and @room.keep_flag == "OFF"
    #  flash[:tweet_notice] = "<span style=\"color: red;\">Twitter連携もしくはTweet保管をONにして下さい。</span>"
    #end

    redirect_to :action => "show", :id => params[:id] and return
  end
  
  #------------#
  # char_count #
  #------------#
  def char_count
    render :text => ( 140 - 1 - params[:value].split(//u).length - params[:hash_tag_length].to_i )
  end


end
