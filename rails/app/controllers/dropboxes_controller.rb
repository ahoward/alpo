class DropboxesController < ApplicationController
  # GET /dropboxes
  # GET /dropboxes.xml
  def index
    @dropboxes = Dropbox.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dropboxes }
    end
  end

  # GET /dropboxes/1
  # GET /dropboxes/1.xml
  def show
    @dropbox = Dropbox.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dropbox }
    end
  end

  # GET /dropboxes/new
  # GET /dropboxes/new.xml
  def new
    @dropbox = Dropbox.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dropbox }
    end
  end

  # GET /dropboxes/1/edit
  def edit
    @dropbox = Dropbox.find(params[:id])
  end

  # POST /dropboxes
  # POST /dropboxes.xml
  def create
    @dropbox = Dropbox.new(params[:dropbox])

    respond_to do |format|
      if @dropbox.save
        flash[:notice] = 'Dropbox was successfully created.'
        format.html { redirect_to(@dropbox) }
        format.xml  { render :xml => @dropbox, :status => :created, :location => @dropbox }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dropbox.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dropboxes/1
  # PUT /dropboxes/1.xml
  def update
    @dropbox = Dropbox.find(params[:id])

    respond_to do |format|
      if @dropbox.update_attributes(params[:dropbox])
        flash[:notice] = 'Dropbox was successfully updated.'
        format.html { redirect_to(@dropbox) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dropbox.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dropboxes/1
  # DELETE /dropboxes/1.xml
  def destroy
    @dropbox = Dropbox.find(params[:id])
    @dropbox.destroy

    respond_to do |format|
      format.html { redirect_to(dropboxes_url) }
      format.xml  { head :ok }
    end
  end
end
