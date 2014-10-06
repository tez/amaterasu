# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  login           :string(255)      not null
#  email           :string(255)      not null
#  first_name      :string(255)      not null
#  last_name       :string(255)      not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'
\
describe User do

  before do
    @user = User.new(login: 'hoge',
                     email: 'hoge@example.com',
                     first_name: 'hoge',
                     last_name: 'hoge',
                     password: 'foobar',
                     password_confirmation: 'foobar')
  end

  subject { @user }

  it { is_expected.to respond_to(:login) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:first_name) }
  it { is_expected.to respond_to(:last_name) }
  it { is_expected.to respond_to(:password_digest) }
  it { is_expected.to respond_to(:password) }
  it { is_expected.to respond_to(:remember_token)}
  it { is_expected.to respond_to(:authenticate) }

  it { is_expected.to be_valid }

  describe 'when first_name is not present' do
    before { @user.first_name = ' ' }
    it { is_expected.not_to be_valid }
  end

  describe 'when last_name is not present' do
    before { @user.last_name = ' ' }
    it { is_expected.not_to be_valid }
  end

  describe 'when email is not present' do
    before { @user.email = ' ' }
    it { is_expected.not_to be_valid }
  end

  describe 'when first_name is too long' do
    before { @user.first_name = 'a' * 51 }
    it { is_expected.not_to be_valid }
  end

  describe 'when last_name is too long' do
    before { @user.last_name = 'a' * 51 }
    it { is_expected.not_to be_valid }
  end

  describe 'when email format is invalid' do
    it 'should be invalid' do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe 'when email format is valid' do
    it 'should be valid' do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe 'when email address is already taken' do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { is_expected.not_to be_valid }
  end

  describe 'when password is not present' do
    before do
      @user = User.new(login: 'foo',
                       email: 'foo@example.com',
                       first_name: 'foo',
                       last_name: 'foo',
                       password: ' ',
                       password_confirmation: ' ')

    end
    it { is_expected.not_to be_valid }
  end

  describe 'when password does not match confirmation' do
    before { @user.password_confirmation = 'mismatch' }
    it { is_expected.not_to be_valid }
  end

  describe 'with a password that is too short' do
    before { @user.password = @user.password_confirmation = 'a' * 5 }
    it { is_expected.to be_invalid }
  end

  describe 'return value of authenticate method' do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe 'with valid password' do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe 'with invalid password' do
      let(:user_for_invalid_password) { found_user.authenticate('invalid') }

      it { is_expected.not_to eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_falsey }
    end
  end

  describe 'remember token' do
    before { @user.save }
    it { expect(:remember_token).not_to be_blank }
  end


end
