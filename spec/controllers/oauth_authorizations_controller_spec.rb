require 'spec_helper'

describe OauthAuthorizationsController do

  let(:omniauth_hash) { {'provider' => 'facebook', 'uid' => '3848729340', 'info' => { :email => 'testerboy@gmail.com' }}}
  let(:auth_user) { FactoryGirl.create(:user, :verified => true) }

  before do
    @request.env['omniauth.auth'] =  omniauth_hash
  end

  def create_auth
    get :create, :provider => omniauth_hash['provider']
  end

  describe "GET /create" do

    let(:omniauth_user_attributes) { {:provider=>"facebook", :uid=>"3848729340", :token=>nil, :secret=>nil, :full_name=>nil, :email=>nil, :nickname=>nil, :last_name=>nil, :first_name=>nil, :link=>nil, :photo_url=>nil, :locale=>nil, :location=>nil, :about=>nil, :avatar_url=>nil} }
    let(:auth) { FactoryGirl.build(:authorization, :user => auth_user) }

    it "receives the extracted omniauth user attributes from the omniauth hash" do
      controller.should_receive(:extract_user_attributes).with(omniauth_hash).and_return(omniauth_user_attributes)
      create_auth
    end

    it "fetches the authorization record of the current omniauth call back" do
      Authorization.should_receive(:find_from_omniauth_hash).with(omniauth_user_attributes)
      create_auth
    end

    context "when a current user session exists" do
      before do
        controller.stub(:current_user).and_return(auth_user)
      end

      context "when an authorization record already exists for the current provider and uid" do

        before do
          Authorization.stub(:find_from_omniauth_hash).and_return(auth)
        end

        it "does not create a new authorization" do
          auth_user.should_not_receive(:new_omniauth_authorizer)
          create_auth
        end

        it "sets a flash error" do
          create_auth
          flash_message = "The #{omniauth_user_attributes[:provider]} account you chose to associate has already been used by a different user."
          flash[:error].should eql flash_message
        end
      end

      context "when there is no authorization record in existence for the current provider and uid" do

        before do
          Authorization.stub(:find_from_omniauth_hash).and_return(nil)
        end

        it "creates a new authorization for the current user" do
          auth_user.should_receive(:new_omniauth_authorizer).with(omniauth_user_attributes)
          create_auth
        end

        it "sets a flash notice" do
          create_auth
          flash_message = "Successfully added #{omniauth_user_attributes[:provider]} authentication."
          flash[:notice].should eql flash_message
        end
      end

      it "redirects to the edit user profile path" do
        create_auth
        response.should redirect_to(edit_user_profile_path(auth_user))
      end

    end

    context "when there is no current user session" do

      before do
        controller.stub(:current_user).and_return(nil)
      end

      context "when an authorization record already exists for the current provider and uid" do
        before do
          Authorization.stub(:find_from_omniauth_hash).and_return(auth)
        end

        context "when the user has been verified" do
          before do
            auth.user.stub(verified?: true)
          end

          context "when the user has used his current omniauth account ( current callback ) to associate another omniauth account ( a previous callback )" do

            before do
              session[:omniauth_params] = omniauth_user_attributes
            end

            it "creates a new authorization for the user provided that he doesn't have a different authorization record with the current provider" do
              auth_user.stub(:omniauth_provider_exists?).and_return(false)
              auth_user.should_receive(:new_omniauth_authorizer).with(omniauth_user_attributes)
              create_auth
            end

            it "sets a flash error if a different authorization record exists for the current provider" do
              auth_user.stub(:omniauth_provider_exists?).and_return(true)
              create_auth
              flash_message = "You have already used a #{session[:omniauth_params][:provider]} account to authorize yourself."
              flash[:error].should eql flash_message
            end
          end

          it "sets a welcome flash notice" do
            create_auth
            flash_message = "Welcome #{auth_user.user_name}"
            flash[:notice].should eql flash_message
          end

          it "creates a new user session" do
            UserSession.should_receive(:create!).with(auth.user, true)
            create_auth
          end

          it "redirects to the user show page" do
            create_auth
            response.should redirect_to(user_path(auth_user))
          end
        end

        context "when the user is not verified" do

          before do
            auth.user.stub(verified?: false)
          end

          it "sets a flash error with the appropriate message" do
            create_auth
            flash[:error].should_not be_nil
          end

          it "redirects to the root path" do
            create_auth
            response.should redirect_to(root_path)
          end
        end

      end

      context "when there is no authorization record in existence for the current provider and uid" do

        before do
          Authorization.stub(:find_from_omniauth_hash).and_return(nil)
        end

        context "the user has tried to login with the current omniauth account ( the current callback )" do
          it "sets the omniauth_params in the session equal to the current omniauth user attributes hash" do
            create_auth
            session[:omniauth_params].should eql omniauth_user_attributes
          end
        end

        context "the user has used his current omniauth account ( current callback ) to associate another omniauth account ( a previous callback )" do

          before do
            session[:omniauth_params] = omniauth_user_attributes
          end

          it "sets a flash error" do
            create_auth
            flash[:error].should_not be_nil
          end
        end

        it "renders the create template" do
          create_auth
          response.should render_template("create")
        end

      end
    end
  end

  describe "GET /destroy" do

    let(:auth_user) { FactoryGirl.create(:user, :verified => true) }
    let(:auth) { FactoryGirl.create(:authorization, :user => auth_user) }

    before do
      controller.stub(current_user: auth_user)
    end

    it "deletes the current user's authorization for the specified provider" do
      get :destroy, :provider => auth.provider
      auth_user.authorizations.find_by_provider('facebook').should eql nil
    end

    it "sets a flash notice and redirects to edit profile page of the user" do
      get :destroy, :provider => auth.provider
      flash_message = "Your #{auth.provider} authentication has been removed"
      flash[:notice].should eql flash_message
      response.should redirect_to(edit_user_profile_path(auth_user))
    end
  end

end
