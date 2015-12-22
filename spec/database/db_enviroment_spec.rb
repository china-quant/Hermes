require 'database/db_enviroment'

describe DBenviroment do
  
  it "DBenviroment return a enviroment object after load!" do
    expect(DBenviroment.load!).to be_a DBenviroment
  end

  it "all the db enviroment config wrap in a DBenviroment object methods" do
    expect(AppDB.enviroment).to be_a DBenviroment
    expect(AppDB.enviroment.user).to eq "root"
    expect(AppDB.enviroment.password).to eq "123456"
  end

end
