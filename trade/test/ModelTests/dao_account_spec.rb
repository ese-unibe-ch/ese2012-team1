require 'test_require'

describe DAOItem do
  before(:each) do
    @items = double("Items")
    DAOItem.stub(:instance).and_return(@items)

    @accounts = Models::DAOAccount.instance

    @accounts.reset
  end

  def double_user(name, id)
    user = double(name)

    user.should_receive(:id).and_return(nil)
    user.should_receive(:id=).with(id)
    user.stub(:id).and_return(id)
    user.stub(:organisation).and_return(false)

    user
  end

  def add_users
    @users = {  :momo => double_user("Momo", 0),
                :beppo => double_user("Peppo", 1),
                :kassiopeia => double_user("Kassiopeia", 2) }

    @accounts.add_account(@users[:momo])
    @accounts.add_account(@users[:beppo])
    @accounts.add_account(@users[:kassiopeia])
  end

  context "when created" do
    it "two instances should be the same" do
      accounts_a = Models::DAOAccount.instance
      accounts_b = Models::DAOAccount.instance
      (accounts_a == accounts_b).should be_true
    end

    it "should add users" do
      @accounts.count_accounts.should == 0

      meister_hora = double("Meister Hora")

      meister_hora.should_receive(:id).and_return(nil)
      meister_hora.should_receive(:id=).with(0)
      meister_hora.stub(:id).and_return(0)

      @accounts.add_account(meister_hora)

      @accounts.count_accounts.should == 1
    end

    it "should fail when_adding user twice" do
      meister_hora = double("Meister Hora")

      meister_hora.should_receive(:id).and_return(nil)
      meister_hora.should_receive(:id=).with(0)
      meister_hora.stub(:id).and_return(0)

      @accounts.add_account(meister_hora)
      @accounts.account_exists?(meister_hora.id).should be_true;

      lambda{ DAOAccount.instance.add_account(meister_hora) }.should raise_error(RuntimeError)
    end

    context "when users are added" do
      before(:each) do
        add_users
      end

      context "when organisation is added" do
        before(:each) do
          @organisation = double_user("Organisation", 3)
          @organisation.stub(:organisation).and_return(true)
          @accounts.add_account(@organisation)

          @users[:momo].stub(:is_member?).and_return(false)
          @users[:beppo].stub(:is_member?).and_return(false)
          @users[:kassiopeia].stub(:is_member?).and_return(false)

        end

        it "should return true if user is part of added organisation and admin" do
          @organisation.should_receive(:is_member?).with(@users[:momo]).and_return(true)
          @organisation.should_receive(:is_admin?).with(@users[:momo]).and_return(true)
          @accounts.admin_of_an_organisation?(@users[:momo]).should be_true
        end

        it "should return false if user is part of added organisation but not admin" do
          @organisation.should_receive(:is_member?).with(@users[:momo]).and_return(true)
          @organisation.should_receive(:is_admin?).with(@users[:momo]).and_return(false)
          @accounts.admin_of_an_organisation?(@users[:momo]).should be_false
        end

        it "should return false if user not part of organisation" do
          @organisation.should_receive(:is_member?).with(@users[:momo]).and_return(false)
          @accounts.admin_of_an_organisation?(@users[:momo]).should be_false
        end

        it "should return false if there are multiple admin" do
          @organisation.should_receive(:is_member?).with(@users[:momo]).and_return(true)
          @organisation.should_receive(:is_last_admin?).with(@users[:momo]).and_return(false)

          @accounts.is_last_admin?(@users[:momo]).should be_false
        end

        it "should return true if there is only one admin" do
          @organisation.should_receive(:is_member?).with(@users[:momo]).and_return(true)
          @organisation.should_receive(:is_last_admin?).with(@users[:momo]).and_return(true)

          @accounts.is_last_admin?(@users[:momo]).should be_true
        end

        it "should reset all member limits" do
          @organisation.should_receive(:reset_member_limits)

          @accounts.reset_all_member_limits
        end
      end


      it "should fetch added users by id" do
        fetched1 = @accounts.fetch_account(@users[:beppo].id)
        fetched2 = @accounts.fetch_account(@users[:momo].id)

        fetched1.should == @users[:beppo]
        fetched2.should == @users[:momo]
      end

      it "should fetch added users by email" do
        @users[:beppo].should_receive(:respond_to?).and_return(true)
        @users[:beppo].should_receive(:email).and_return("beppo@mail.ch")

        fetched = @accounts.fetch_user_by_email("beppo@mail.ch")

        fetched.should == @users[:beppo]
      end

      it "should return false when registration hash doesn't exist" do
        @users[:beppo].stub(:organisation).and_return(false)
        @users[:beppo].should_receive(:reg_hash).and_return(1)
        @users[:momo].stub(:organisation).and_return(false)
        @users[:momo].should_receive(:reg_hash).and_return(1)
        @users[:kassiopeia].stub(:organisation).and_return(false)
        @users[:kassiopeia].should_receive(:reg_hash).and_return(1)

        @accounts.reg_hash_exists?(0).should be_false
      end

      it "should fetch all users but one" do
        fetched = @accounts.fetch_all_users_but(@users[:momo].id)

        fetched.include?(@users[:momo]).should be_false
        fetched.include?(@users[:kassiopeia]).should be_true
        fetched.include?(@users[:beppo]).should be_true
      end

      it "should remove added users by id" do
        @accounts.remove_account(@users[:kassiopeia].id)

        @accounts.count_accounts.should == 2
        @accounts.account_exists?(@users[:kassiopeia].id).should be_false
        @accounts.account_exists?(@users[:beppo].id).should be_true
        @accounts.account_exists?(@users[:momo].id).should be_true

        @accounts.remove_account(@users[:beppo].id)
        @accounts.remove_account(@users[:momo].id)

        @accounts.count_accounts.should == 0
      end

      it "should fetch all but one accounts" do
        others = @accounts.fetch_all_accounts_but(@users[:momo].id)
        others.size.should == 2
        others.include?(@users[:beppo]).should be_true
        others.include?(@users[:kassiopeia]).should be_true
      end
    end
  end

  # ---- organisation ---------------------

  it "should add organisation" do
    @accounts.add_account(double_user("Organisation", 0))
    @accounts.count_accounts.should == 1
  end

  context "when organisation was added" do
    before(:each) do
      add_users

      @organisation = double_user("Organisation", 3)
      @accounts.add_account(@organisation)
    end

    it "should fetch organisation" do
      @accounts.fetch_account(@organisation.id).should == @organisation
    end

    # Testing only the case, that organisation has one user
    it "should fetch organisation of user" do
      @users[:momo].should_receive(:is_member?).with(@users[:kassiopeia]).and_return(false)
      @users[:kassiopeia].should_receive(:is_member?).with(@users[:kassiopeia]).and_return(false)
      @users[:beppo].should_receive(:is_member?).with(@users[:kassiopeia]).and_return(false)
      @organisation.should_receive(:is_member?).with(@users[:kassiopeia]).and_return(true)

      @accounts.fetch_organisations_of(@users[:kassiopeia].id).include?(@organisation).should be_true
    end

    it "test_should_remove_organisation" do
      @accounts.account_exists?(@organisation.id).should be_true

      @accounts.remove_account(@organisation.id)

      @accounts.account_exists?(@organisation.id).should be_false
    end
  end
end