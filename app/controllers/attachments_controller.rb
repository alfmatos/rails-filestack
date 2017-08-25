class AttachmentsController < ApplicationController
  before_action :set_attachment, only: [:show, :edit, :update, :destroy]

  # GET /attachments
  # GET /attachments.json
  def index
    @attachments = Attachment.all
  end

  # GET /attachments/1
  # GET /attachments/1.json
  def show
  end

  # GET /attachments/new
  def new
    @attachment = Attachment.new
  end

  # GET /attachments/1/edit
  def edit
  end

  # POST /attachments
  # POST /attachments.json
  def create
    file_path = Rails.root.join("public", "baboon.png")
    filestack_service(key: "",
                      secret: "")
    filelink = upload(file_path)

    @attachment = Attachment.new(attachment_params)
    @attachment.handle = filelink.handle

    respond_to do |format|
      if @attachment.save
        format.html { redirect_to @attachment, notice: 'Attachment was successfully created.' }
        format.json { render :show, status: :created, location: @attachment }
      else
        format.html { render :new }
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attachments/1
  # PATCH/PUT /attachments/1.json
  def update
    respond_to do |format|
      if @attachment.update(attachment_params)
        format.html { redirect_to @attachment, notice: 'Attachment was successfully updated.' }
        format.json { render :show, status: :ok, location: @attachment }
      else
        format.html { render :edit }
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attachments/1
  # DELETE /attachments/1.json
  def destroy
    @attachment.destroy
    respond_to do |format|
      format.html { redirect_to attachments_url, notice: 'Attachment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_attachment
      @attachment = Attachment.find(params[:id])
    end

    def attachment_params
      params.require(:attachment).permit(:title, :handle)
    end

    def filestack_service(key:, secret:)
      security_options = {
        "expiry": 10.years.to_i,
        "call": ["pick", "store", "read", "convert", "remove"]
      }

      security = FilestackSecurity.new(secret, options: security_options)
      @client = FilestackClient.new(key, security: security)
    end

    def upload(path)
      @client.upload(filepath: path, multipart: false)
    end

    def delete(handle)
      filelink = remote_file(handle)
      filelink.delete
    end

    def remote_file(handle)
      FilestackFilelink.new(handle,
                            security: @client.security,
                            apikey: @client.apikey)
    end

    def remote_attachment(handle)
      remote_file(handle).transform
    end

    def remote_url(handle)
      remote_attachment(handle).url
    end
end
