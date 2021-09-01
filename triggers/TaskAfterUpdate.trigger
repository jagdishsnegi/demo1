trigger TaskAfterUpdate on Task (after Update) {
    Set<Id> tskForEmail = new Set<Id>();
    Set<Id> sOwnerandCreator = new Set<Id>();
    for(Task tsk : Trigger.new){
        if(tsk.Send_Email_When_Task_Is_Completed__c == true  &&  tsk.Status == 'Completed'){
            tskForEmail.add(tsk.Id);
            sOwnerandCreator.add(tsk.OwnerId);
            sOwnerandCreator.add(tsk.CreatedById);
        }
    }
    if(!sOwnerandCreator.isEmpty()){
        Map<Id, User> mUsr = new Map<Id, User>([SELECT id, email, name FROM User WHERE id IN: sOwnerandCreator]);
        List<Messaging.SingleEmailMessage> sendMail = new List<Messaging.SingleEmailMessage>();
        
        for(Id tId: tskForEmail){
            Task tempT = Trigger.newMap.get(tId);
            
            string fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tempT.Id;
            
            Messaging.SingleEmailMessage taskMail = new Messaging.SingleEmailMessage();
                taskMail.setToAddresses(new String[]{ mUsr.get(tempT.OwnerId).Email, mUsr.get(tempT.CreatedById).Email });

                taskMail.setSubject(tempT.Subject);
                    String str ='';
                    str += '<table width="100%">';
                    str += '<tr>';
                    str += '<td colspan="2" width="100%" align="left"><b>' + mUsr.get(tempT.OwnerId).Name + '<b/> has completed below task.<br/><br/><br/></td>';
                    str += '</tr>';
                    str += '<tr>';
                    str += '<td width="25%" align="right"><b>Related To&nbsp;&nbsp;</b></td>';
                    str += '<td width="75%" align="left">' + tempT.Subject + '</td>';
                    str += '</tr>';
                    str += '<tr>';
                    str += '<td width="25%" align="right"><b>Date Completed&nbsp;&nbsp;</b></td>';
                    str += '<td width="75%" align="left">' + tempT.LastModifiedDate + '</td>';
                    str += '</tr>';
                    str += '<tr>';
                    str += '<td width="25%" align="right"><b>Priority&nbsp;&nbsp;</b></td>';
                    str += '<td width="75%" align="left">' + tempT.Priority + '</td>';
                    str += '</tr>';
                    str += '<tr>';
                    str += '<td width="25%" align="right"><b>Comments&nbsp;&nbsp;</b></td>';
                    str += '<td width="75%" align="left">' + ((String.isNotBlank(tempT.Description)) ? tempT.Description : '') + '</td>';
                    str += '</tr>';
                    str += '<tr>';
                    str += '<td colspan="2" width="100%" align="left"><br/>For more details, click the following link :<br/><a href="' + fullRecordURL + '" target="_blank">' + fullRecordURL + '</a></td>';
                    str += '</tr>';
                    str += '</table>'; 
                taskMail.setHTMLBody(str);
            sendMail.add(taskMail);     
        }
        if(!sendMail.isEmpty()){
            Messaging.sendEmail(sendMail);
System.debug('>>> Task Email Sent.\nTotal Email: ' + sendMail.size() + '\nsendMail: ' + sendMail);          
        }
    }
}