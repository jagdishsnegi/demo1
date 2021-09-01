trigger beforeContactDelete on Contact (before delete) {
    
    List<string> deleteConList = new List<string>();
    for(Contact con: [select id,name,account.ownerid,ownerid,RecordTypeId,account.recordtypeid from contact where id in:Trigger.old]) {   
        deleteConList.add(con.id);
    }
    ContactBeforeDeleteHandler deletehandler = new ContactBeforeDeleteHandler ();
    set<id> errortodisplay = deletehandler.validateDeleteRequest(deleteConList);
    Map<id,contact> Mapjun = Trigger.oldmap;
    for(id oldid : errortodisplay) {
        
        Mapjun.get(oldid).adderror('You do not have permissions to delete a contact, because you are not the account owner. Please reach out to @Digital for further assistance.');
    }
}