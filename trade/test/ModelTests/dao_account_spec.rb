require 'test_require'

describe DAOItem do
  before(:each) do
    @items = Models::DAOItem.instance
    @accounts = Models::DAOAccount.instance

    @accounts.reset
    @items.reset
  end

  def double_user(name, id)
    user = double(name)

    user.should_receive(:id).and_return(nil)
    user.should_receive(:id=).with(id)
    user.stub(:id).and_return(id)

    user
  end

  def double_item(name, id, owner)
    item = double(name)
    item.should_receive(:id).and_return(nil)
    item.should_receive(:id=).with(id)
    item.stub(:id).and_return(id)
    item.stub(:owner).and_return(owner)

    item
  end

  def add_users
    @users = {  :momo => double_user("Momo", 0),
                :beppo => double_user("Peppo", 1),
                :kassiopeia => double_user("Kassiopeia", 2) }

    @accounts.add_account(@users[:momo])
    @accounts.add_account(@users[:beppo])
    @accounts.add_account(@users[:kassiopeia])
  end

  def add_items
    @some_items = { :curly_hair => double_item("Curly Hair", 0, @users[:momo]),
                    :sand => double_item("Hourflower", 1, @users[:momo]),
                    :broom => double_item("Broom", 2, @users[:beppo]),
                    :time => double_item("Time", 3, @users[:kassiopeia]) }

    @items.add_item(@some_items[:curly_hair])
    @items.add_item(@some_items[:sand])
    @items.add_item(@some_items[:broom])
    @items.add_item(@some_items[:time])
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
      @accounts.user_exists?(meister_hora.id).should be_true;

      lambda{ DAOAccount.instance.add_account(meister_hora) }.should raise_error(RuntimeError)
    end

    context "when users are added" do
      before(:each) do
        add_users
      end


      it "should fetch added users by id" do
        fetched1 = @accounts.fetch_account(@users[:beppo].id)
        fetched2 = @accounts.fetch_account(@users[:momo].id)

        fetched1.should == @users[:beppo]
        fetched2.should == @users[:momo]
      end

      it "should remove added users by id" do
        @users[:kassiopeia].should_receive(:avatar).and_return("/images/users/default_avatar.png" )
        @users[:beppo].should_receive(:avatar).and_return("/images/users/default_avatar.png" )
        @users[:momo].should_receive(:avatar).and_return("/images/users/default_avatar.png" )

        @accounts.remove_account(@users[:kassiopeia].id)

        @accounts.count_accounts.should == 2
        @accounts.user_exists?(@users[:kassiopeia].id).should be_false
        @accounts.user_exists?(@users[:beppo].id).should be_true
        @accounts.user_exists?(@users[:momo].id).should be_true

        @accounts.remove_account(@users[:beppo].id)
        @accounts.remove_account(@users[:momo].id)

        @accounts.count_accounts.should == 0
      end

      it "should fetch all but one user" do
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

      @organisation.should_receive(:avatar).and_return("/images/users/default_avatar.png" )

      @accounts.remove_account(@organisation.id)

      @accounts.account_exists?(@organisation.id).should be_false
    end
  end
end