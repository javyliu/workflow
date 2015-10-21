class RolesController < ApplicationController
  authorize_resource

  # GET /roles
  # GET /roles.xml
  def index
    @roles = Role.all_without_reserved.page(params[:page]).per(20)
    params.permit!
    con_hash,con_like = construct_condition("role",like_ary: [:name,:display_name])
    drop_page_title("角色管理")
    drop_breadcrumb
    @roles = @roles.where(con_hash).where(con_like)#.tap{|t|Rails.logger.info t.to_sql }
    respond_to do |format|
      format.html # index.html.erb
      format.js { render :partial => "items",:object => @roles,:content_type => Mime::HTML }
    end
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    @role = Role.find(params[:id])

    drop_breadcrumb("角色管理",roles_path)
    drop_page_title("角色详情")
    drop_breadcrumb
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new
    drop_breadcrumb("角色管理",roles_path)
    drop_page_title("新建角色")
    drop_breadcrumb
    #@roles = Game.app_config["roles"][current_user.role]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/1/edit
  def edit
    drop_breadcrumb("角色管理",roles_path)
    drop_page_title("编辑角色")
    drop_breadcrumb
    @role = Role.find(params[:id])
    @roles = Role.all #Game.app_config["roles"][current_user.role]
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(role_params)

    respond_to do |format|
      if @role.save
        ress = []
        params[:role_resource_names].each do |res|
          ress << {resource_name: res,role_id: @role.id} if res.present?
        end
        RoleResource.where(role_id: @role.id).delete_all
        RoleResource.import!(ress)
        format.html { redirect_to(role_path(@role), :notice => 'Role was successfully created.') }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        drop_breadcrumb("角色管理",roles_path)
        drop_page_title("创建角色")
        drop_breadcrumb
        flash.now[:alert] = @role.errors.full_messages.join("")
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])
    @role.assign_attributes(role_params)
    @role.updated_at = Time.now

    respond_to do |format|
      if @role.save
        ress = []
        params[:role_resource_names].each do |res|
          ress << {resource_name: res,role_id: @role.id} if res.present?
        end
        RoleResource.where(role_id: @role.id).delete_all
        RoleResource.import!(ress)
        format.html { redirect_to(role_path(@role), :notice => 'Role was successfully updated.') }
        format.xml  { head :ok }
      else
        @roles = Game.all
        flash.now[:alert] = @role.errors.full_messages
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_path) }
      format.xml  { head :ok }
      format.json { head :no_content}
    end
  end

  private
  def role_params
    params.require(:role).permit(:name,:display_name)
  end
end

