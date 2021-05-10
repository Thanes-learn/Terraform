import MySQLdb
import logging
print("connecting DB")
try:
    # Connecting RDS Service 
    db = MySQLdb.connect(host="mysqlinsta.c065vc4pnlfy.us-east-2.rds.amazonaws.com",
                     user="root",
                     passwd="rtsawsadmin")

    # printing connection status
    print(str(db))

    # Checking SQL query running performance
    cur = db.cursor()
    cur.execute("SELECT VERSION()")
    data = cur.fetchone()
    print("Database version : %s " % data)

    #Creating Schema and Table -- IT will not delete if you mistakely execute this scipt
    cur.execute("CREATE SCHEMA  IF NOT EXISTS LOGS")
    cur.execute("CREATE TABLE IF NOT EXISTS `LOGS`.`WEB_LOGS` (`LOG_ID` INT NOT NULL AUTO_INCREMENT,`LOG_MSG` VARCHAR(255) NOT NULL,`LOG_TIME` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,PRIMARY KEY (`LOG_ID`))")
    db.commit()

    #var="Testing Result"
    #sql = "insert into LOGS.WEB_LOGS(log_msg) values('"+var+"')"
    #cur.execute(sql)
    #db.commit()
    #data = cur.fetchone()

    # Closing DB Connection -- If not, It will utlize all available pools and we will connection issue
    db.close()
except Exception as e:
    #display DB Error if there is problem
    print("Database connectivity issue \nDB_ERROR"+str(e)+"\n")
