class Product < ActiveRecord::Base
  has_deja_vue :associations => [:supplier], :ignore => [:dimensions]
  belongs_to :supplier
end

class Supplier < ActiveRecord::Base
	has_deja_vue
  has_many :products
end


# A mock class simulating an ActiveRecord class that is going to be versionated
class User < ActiveRecord::Base
  
  belongs_to :account

  def version_changes
    # mocked method that simply returns that name field has changed
    [:login]
  end

  def tag_list
    @tag_list
  end

  def tag_list=(args)
    @tag_list = args
  end

end

class Account < ActiveRecord::Base
  has_many :users
end
