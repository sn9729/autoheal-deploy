const mongoose = require('mongoose');
const uri = "mongodb+srv://mailtosynrao_db_user:BFuWGnObUOtt74Sl@cluster0.0y02ksi.mongodb.net/taskmanager?appName=Cluster0";

mongoose.connect(uri)
  .then(() => {
    console.log("Connected successfully");
    process.exit(0);
  })
  .catch(err => {
    console.error("Connection error:", err);
    process.exit(1);
  });
