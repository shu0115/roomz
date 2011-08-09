# coding: utf-8
class RoomsController < ApplicationController

  #-------#
  # index #
  #-------#
  def index
    @rooms = Room.all
  end

  #------#
  # show #
  #------#
  def show
    @room = Room.find( params[:id] )
  end

  #-----#
  # new #
  #-----#
  def new
    @room = Room.new
  end

  #------#
  # edit #
  #------#
  def edit
    @room = Room.find( params[:id] )
  end

  #--------#
  # create #
  #--------#
  def create
    @room = Room.new( params[:room] )

    if @room.save
      flash[:notice] = "Room was successfully created."
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
      flash[:notice] = "Room was successfully updated."
      redirect_to :action => "show", :id => params[:id]
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

end
