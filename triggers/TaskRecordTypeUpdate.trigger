trigger TaskRecordTypeUpdate on Task (before insert) {
    Map<String, Id>  taskDeveloperNameToId = SFDCSpecialUtilities.GetRecordTypeIdsByDeveloperName(Task.SobjectType);

    for(Task t : Trigger.New){
        if(t.Subject != null){
            if(t.Subject.contains('Structural Support Task')) {
                t.RecordTypeId = taskDeveloperNameToId.get('Structural_Support');
            }
            if(t.Subject.contains('Performance Support Task')) {
                t.RecordTypeId = taskDeveloperNameToId.get('Performance_Support');
            }
        }
    }

}