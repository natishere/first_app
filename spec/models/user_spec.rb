require 'spec_helper'

describe User do
  before(:each) do
    @attr = { 
	  :name => "Example User",
	  :email => "user@example.com",
	  :password => "secret",
	  :password_confirmation => "secret"
	}
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end  
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
	no_name_user.should_not be_valid
  end
  
  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
	no_email_user.should_not be_valid
  end
  
  it "should reject names > 50 chars long" do
    too_long_name = 'x' * 51
	longed_name_user = User.new(@attr.merge(:name => too_long_name))
	longed_name_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    vems = %w[ a@b.c a_ff@nbn.jgfhj a_jhj@hgh.kjhk.com]
	vems.each do |vem|
	  valid_email_user = User.new(@attr.merge(:email => vem))
	  valid_email_user.should be_valid
	end  
  end
  
  it "should reject invalid email addresses" do
    ieas = %w[ a.com @kjk @.jhj abc.com@ aa@kjkj ]
	ieas.each do |iea|
	  invalid_email_user = User.new(@attr.merge(:email => iea))
	  invalid_email_user.should_not be_valid
	end
  end
  
  it "should reject duplicate email addresses users - ignoring case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
	duplicate_email_user = User.new(@attr)
	duplicate_email_user.should_not be_valid
  end
  
  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
    end
  
    it "should require a matching password" do
       User.new(@attr.merge(:password_confirmation => 'abcd')).should_not be_valid
    end
  
    it "should reject short passwords" do
      short_pass = 'x' * 5
      User.new(@attr.merge(:password => short_pass, :password_confirmation => short_pass)).should_not be_valid
    end
  
    it "should reject long passwords" do
      long_pass = 'x' * 41
      User.new(@attr.merge(:password => long_pass, :password_confirmation => long_pass)).should_not be_valid
    end
  
  end
  
  describe "password encryption" do
  
    before(:each) do
	  @user = User.create!(@attr)
	end
	
    it "should have an encrypted password attribute" do
	  @user.should respond_to(:encrypted_password)
	end
	
	it "should set the encrypted password" do
	  @user.encrypted_password.should_not be_blank
	end
	
	describe "has_password? method" do
		it "should be true if passwords match" do
			@user.has_password?(@attr[:password]).should be_true
		end
		it "should be false if passwords don't match" do
			@user.has_password?('invalid').should be_false
		end
	end
	
	describe "authenticate_method" do
		it "should return nil on email/password missmatch" do
			wrong_password_user=User.authenticate(@attr[:email], 'wrong_password')
			wrong_password_user.should be_nil
		end
		it "should return nil for no email match" do
			no_email_user=User.authenticate('wrong_password', @attr[:password] )
			no_email_user.should be_nil
		end
		it "should return the user on email/password match" do
			ret=User.authenticate(@attr[:email], @attr[:password] )
			ret.should == @user
		end
	end
	
	describe "admin attribute" do
		before(:each) do
			@user = User.create!(@attr)
		end
		it "should respond to admin" do
			@user.should respond_to(:admin)
		end
		it "should not be an admin by default" do
			@user.should_not be_admin
		end
		it "should be convirtible to admin" do
			@user.toggle!(:admin)
			@user.should be_admin
		end
	end
	
  end

end
