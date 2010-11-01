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
			#before(:each) do
				#@user = User.create!(@attr)
			#end
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
	describe "micropost associations" do
		before(:each) do
			@user = User.create(@attr)
			@mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
			@mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
		end
		it "should have a microposts attribute" do
			@user.should respond_to(:microposts)
		end
		it "should have the right micropost in the right order" do
			@user.microposts.should == [@mp2, @mp1]
		end
		it "should destroy associated microposts" do
			@user.destroy
			[@mp1,@mp2].each do |micropost|
				Micropost.find_by_id(micropost.id).should be_nil
			end	
		end
		describe "status feed" do
		
			it "should have a feed" do
				@user.should respond_to(:feed)
			end
			
			it "should include the user's microposts" do
				@user.feed.should include(@mp1)
				@user.feed.should include(@mp2)
			end
			
			it "should not include a different user's microposts" do
				@mp3 = Factory(:micropost, 
							   :user => Factory(:user, :email => Factory.next(:email)))
				@user.feed.should_not include(@mp3)
			end
			
			it "should include the microposts of followed users" do
				followed = Factory(:user, :email => Factory.next(:email))
				mp3 = Factory(:micropost, :user => followed)
				@user.follow!(followed)
				@user.feed.should include(mp3)
			end
		end
	end
	describe "relationships" do
		before(:each) do
			@user = User.create!(@attr)
			@followed = Factory(:user)
		end
		
		it "should have a relationships method" do
			@user.should respond_to(:relationships)
		end
		
		it "should have a following method" do
			@user.should respond_to(:following)
		end
		
		it "should have a following? method" do
			@user.should respond_to(:following?)
		end
		
		it "should have a follow! method" do
			@user.should respond_to(:follow!)
		end
		
		it "should follow another user" do
			@user.follow!(@followed)
			@user.should be_following(@followed)
		end
		
		it "should include the followed user in the following array" do
			@user.follow!(@followed)
			@user.following.should include(@followed)
		end
		
		it "should unfollow a user" do
			@user.follow!(@followed)
			@user.unfollow!(@followed)
			@user.should_not be_following(@followed)
		end
		
		it "should have a reverse_relationships method" do
			@user.should respond_to(:reverse_relationships)
		end
		
		it "should have followers method" do
			@user.should respond_to(:followers)
		end
		
		it "should include the follower in the followers array" do
			@user.follow!(@followed)
			@followed.followers.should include(@user)
		end
	end
end
