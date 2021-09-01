/********************************************************************************************************************
Name    : CreateManualEUInspectionSharing
Author  : Aashish Mathur
Date    : 23 December, 2010
Usage   : Fires after insert/update of Inspection records and creates/updates/deletes Manual Sharings related to
          Reviewers and Inspectors of the EU records.
********************************************************************************************************************/

trigger CreateManualEUInspectionSharing on Inspection__c (after insert, after update) {
    Set<ID> caseIdsSet = new Set<ID>();
    
    for (Inspection__c newIns : Trigger.new) {
        if (newIns.Case__c != null) {
            caseIdsSet.add(newIns.Case__c);
        }
    }
    
    Map<ID, Case> idToCaseMap = new Map<ID, Case>([SELECT Id FROM Case WHERE Id IN :caseIdsSet
            and RecordType.DeveloperName = 'EU_Inspection_Site_Audit_Case']);//for Case#00078518
    List<Inspection__c> insList = new List<Inspection__c>();
    Set<ID> userIdsSet = new Set<ID>();
    Map<ID, InspectionClass> insIdToInsClassMap = new Map<ID, InspectionClass>();
    Set<ID> euCaseIdsSet = new Set<ID>();
    
    for (Inspection__c newIns : Trigger.new) {
        if (newIns.Case__c == null || idToCaseMap.keySet().contains(newIns.Case__c) == false) {
            continue;
        }
        
        Inspection__c oldIns = (Trigger.isUpdate)? Trigger.oldMap.get(newIns.Id) : null;
        
        if (Trigger.isInsert || oldIns.Reviewer__c != newIns.Reviewer__c || oldIns.Contact__c != newIns.Contact__c) {
            insList.add(newIns);
            euCaseIdsSet.add(newIns.Case__c);
            InspectionClass insClass = new InspectionClass((oldIns == null)? null : oldIns.Reviewer__c, newIns.Reviewer__c,
                    (oldIns == null)? null : oldIns.Contact__c, newIns.Contact__c);
            insIdToInsClassMap.put(newIns.Id, insClass);
            
            if (Trigger.isInsert) {
                userIdsSet.add(newIns.Reviewer__c);
                userIdsSet.add(newIns.Contact__c);
            } else {
                if (oldIns.Reviewer__c != newIns.Reviewer__c) {
                    userIdsSet.add(oldIns.Reviewer__c);
                    userIdsSet.add(newIns.Reviewer__c);
                }
                
                if (oldIns.Contact__c != newIns.Contact__c) {
                    userIdsSet.add(oldIns.Contact__c);
                    userIdsSet.add(newIns.Contact__c);
                }
            }
        }
    }
    
    if (userIdsSet.size() == 0) {
        return;
    }
    
    List<Inspection__Share> existingInsShares = [SELECT ParentId, UserOrGroupId, RowCause, AccessLevel FROM Inspection__Share
            WHERE ParentId IN :insIdToInsClassMap.keySet() AND UserOrGroupId IN :userIdsSet];
    Map<String, Inspection__Share> insUserKeyToInsShareMap = new Map<String, Inspection__Share>();
    List<CaseShare> existingCaseShares = [SELECT CaseId, UserOrGroupId, RowCause, CaseAccessLevel FROM CaseShare
            WHERE CaseId IN :euCaseIdsSet AND UserOrGroupId IN :userIdsSet];
    Map<String, CaseShare> caseUserKeyToCaseShareMap = new Map<String, CaseShare>();
    
    for (Inspection__Share exiInsShare : existingInsShares) {
        insUserKeyToInsShareMap.put('' + exiInsShare.ParentId + exiInsShare.UserOrGroupId, exiInsShare);
    }
    
    for (CaseShare exiCaseShare : existingCaseShares) {
        caseUserKeyToCaseShareMap.put('' + exiCaseShare.CaseId + exiCaseShare.UserOrGroupId, exiCaseShare);
    }
    
    List<Inspection__Share> insSharesToUpsert = new List<Inspection__Share>();
    List<Inspection__Share> insSharesToDelete = new List<Inspection__Share>();
    List<CaseShare> caseSharesToUpsert = new List<CaseShare>();
    List<CaseShare> caseSharesToDelete = new List<CaseShare>();
    
    for (Inspection__c newIns : insList) {
        InspectionClass insClass = insIdToInsClassMap.get(newIns.Id);
        Inspection__Share oldReviewerInsShare = insUserKeyToInsShareMap.get('' + newIns.Id + insClass.oldReviewer);
        Inspection__Share newReviewerInsShare = insUserKeyToInsShareMap.get('' + newIns.Id + insClass.newReviewer);
        Inspection__Share oldContactInsShare = insUserKeyToInsShareMap.get('' + newIns.Id + insClass.oldContact);
        Inspection__Share newContactInsShare = insUserKeyToInsShareMap.get('' + newIns.Id + insClass.newContact);
        CaseShare oldReviewerCaseShare = caseUserKeyToCaseShareMap.get('' + newIns.Case__c + insClass.oldReviewer);
        CaseShare newReviewerCaseShare = caseUserKeyToCaseShareMap.get('' + newIns.Case__c + insClass.newReviewer);
        CaseShare oldContactCaseShare = caseUserKeyToCaseShareMap.get('' + newIns.Case__c + insClass.oldContact);
        CaseShare newContactCaseShare = caseUserKeyToCaseShareMap.get('' + newIns.Case__c + insClass.newContact);
        
        if (insClass.oldReviewer != insClass.newReviewer) {
            if (oldReviewerInsShare != null && oldReviewerInsShare.RowCause == 'Manual') {
                insSharesToDelete.add(oldReviewerInsShare);
            }
            if (oldReviewerCaseShare != null && oldReviewerCaseShare.RowCause == 'Manual') {
                caseSharesToDelete.add(oldReviewerCaseShare);
            }
            
            createUpdateInsShare(newReviewerInsShare, newIns.Id, insClass.newReviewer);
            createUpdateCaseShare(newReviewerCaseShare, newIns.Case__c, insClass.newReviewer);
        }
        
        if (insClass.oldContact != insClass.newContact) {
            if (oldContactInsShare != null && oldContactInsShare.RowCause == 'Manual') {
                insSharesToDelete.add(oldContactInsShare);
            }
            if (oldContactCaseShare != null && oldContactCaseShare.RowCause == 'Manual') {
                caseSharesToDelete.add(oldContactCaseShare);
            }
            
            createUpdateInsShare(newContactInsShare, newIns.Id, insClass.newContact);
            createUpdateCaseShare(newContactCaseShare, newIns.Case__c, insClass.newContact);
        }
    }
    
    if (insSharesToDelete.size() > 0) {
        delete insSharesToDelete;
    }
    
    if (insSharesToUpsert.size() > 0) {
        upsert insSharesToUpsert;
    }
    
    if (caseSharesToDelete.size() > 0) {
        delete caseSharesToDelete;
    }
    
    if (caseSharesToUpsert.size() > 0) {
        upsert caseSharesToUpsert;
    }
    
    private void createUpdateInsShare(Inspection__Share insShare, ID newInsId, ID userId) {
        if (insShare != null && (insShare.RowCause != 'Manual' || insShare.AccessLevel == 'Edit')) {
            return;
        }
        
        if (insShare == null) {
            insShare = new Inspection__Share();
            insShare.ParentId = newInsId;
            insShare.UserOrGroupId = userId;
            insShare.RowCause = 'Manual';
        }
        
        insShare.AccessLevel = 'Edit';
        insSharesToUpsert.add(insShare);
    }
    
    private void createUpdateCaseShare(CaseShare caseShare, ID caseId, ID userId) {
        if (caseShare != null && (caseShare.RowCause != 'Manual' || caseShare.CaseAccessLevel == 'Edit')) {
            return;
        }
        
        if (caseShare == null) {
            caseShare = new CaseShare();
            caseShare.CaseId = caseId;
            caseShare.UserOrGroupId = userId;
            //caseShare.RowCause = 'Manual';
        }
        
        caseShare.CaseAccessLevel = 'Edit';
        caseSharesToUpsert.add(caseShare);
    }
    
    private class InspectionClass {
        ID oldReviewer;
        ID newReviewer;
        ID oldContact;
        ID newContact;
        
        private InspectionClass(ID oldReviewer, ID newReviewer, ID oldContact, ID newContact) {
            this.oldReviewer= oldReviewer;
            this.newReviewer= newReviewer;
            this.oldContact= oldContact;
            this.newContact= newContact;
        }
    }
}