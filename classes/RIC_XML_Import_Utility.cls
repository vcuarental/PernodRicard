/* 
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
* Neither the name of the salesforce.com, Inc. nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
global with sharing class RIC_XML_Import_Utility {
    
    global with sharing class XML_Metadata {
        String ExportVersion; 
        String ExportAuthor;
        String ExportPackage;
        String ExportOrganization;
        DateTime ExportCreateDate;
    }
    
    Milestone1_Project__c project;
    List<Milestone1_Milestone__c> milestones;
    List<Milestone1_Milestone__c> subMilestones;
    List<Milestone1_Milestone__c> successorsList;
    List<Milestone1_Task__c> tasks;
    List<Milestone1_Task__c> subTasks;
    XML_Metadata metadata = new XML_Metadata();
    Integer newProjectDuration, oldProjectDuration, newTaskDuration;
    Double proportionaldurationsDifference;
    Date oldProjectStartDate;
    
    global RIC_XML_Import_Utility()
    {
        milestones = new List<Milestone1_Milestone__c>();
        subMilestones = new List<Milestone1_Milestone__c>();
        successorsList =new List<Milestone1_Milestone__c>();
        tasks = new List<Milestone1_Task__c>();
        subTasks = new List<Milestone1_Task__c>();
    }
    
    global Milestone1_Project__c importProject(String xml, Milestone1_Project__c projectP) {
        this.project = projectP;
        this.project.RIC_Date_debut_Planning__c = Date.today();
        Date projectMAD = getProjectMAD(project);
        
        if(projectMAD != null)
            this.newProjectDuration = Date.today().daysBetween(projectMAD);
        System.debug('#### newProjectDuration: ' + newProjectDuration);
        
        Savepoint sp = Database.setSavepoint();
        try{
            Xmlstreamreader reader = new Xmlstreamreader(xml);
            while (reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_META) {
                    parseMeta(reader);
                }
                if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_PROJECT) {
                    parseProject(reader);
                }
                reader.next();
            }
            insertSalesforceObjects();
        }catch(Exception ex){
            Database.rollback(sp);
            throw ex;
        }
        
        return project;
    }
    
    private void insertSalesforceObjects()
    {
        System.debug(LoggingLevel.warn, 'Number of Milestones: ' + this.milestones.size());
        System.debug(LoggingLevel.warn, 'Number of Tasks: ' + this.tasks.size());
        
        for(Milestone1_Milestone__c currentMilestone : milestones)
        {
            currentMilestone.Project__c = project.Id;
            if(currentMilestone.Predecessor_Milestone__c!=null)
            {
                successorsList.add(currentMilestone);
                currentMilestone.Predecessor_Milestone_Import_Id__c=currentMilestone.Predecessor_Milestone__c;
                currentMilestone.Predecessor_Milestone__c=null;
            }
        }
        
        insert milestones;
        
        for(Milestone1_Milestone__c currentMilestone : milestones)
        {
            currentMilestone.Project__c = project.Id;
            matchMilestonesToMilestones(subMilestones,currentMilestone);
        }
        for(Milestone1_Milestone__c currentMilestone : subMilestones)
            if(currentMilestone.Predecessor_Milestone__c!=null)
        {
            successorsList.add(currentMilestone);
            currentMilestone.Predecessor_Milestone_Import_Id__c=currentMilestone.Predecessor_Milestone__c;
            currentMilestone.Predecessor_Milestone__c=null;
        }
        insert subMilestones;
        
        for(Milestone1_Milestone__c currentMilestone : milestones){
            updatePredecessorMilestones(currentMilestone);
        }
        for(Milestone1_Milestone__c currentMilestone: subMilestones){
            updatePredecessorMilestones(currentMilestone);
        }
        
        update successorsList;
        
        for(Milestone1_Task__c currentTask : tasks)
        {
            Boolean foundMatch = false;
            foundMatch = matchTaskToMilestone(milestones,currentTask);
            foundMatch = matchTaskToMilestone(subMilestones,currentTask);
        }
        
        for(Milestone1_Task__c currentTask : tasks)
        {
            currentTask.Predecessor_Task_Import_Id__c=currentTask.Predecessor_Task__c;
            currentTask.Predecessor_Task__c=null;
        }
        insert tasks;
        system.debug('tasks'+tasks);
        
        for(Milestone1_Task__c currentTask : tasks){
            matchTaskToTask(currentTask);
        }
        update subtasks;
        system.debug('subtasks'+subtasks);
        
        update project;
    }
    
    global void updatePredecessorMilestones(Milestone1_Milestone__c currentMilestone){
        
        for(Milestone1_Milestone__c milestone:successorsList){
            
            if(milestone.Predecessor_Milestone_Import_Id__c==currentMilestone.ImportID__c)
            {
                milestone.Predecessor_Milestone__c=currentMilestone.Id;
                milestone.Project__c = currentMilestone.Project__c;
            }
        }
    }
    
    global void matchMilestonesToMilestones(List<Milestone1_Milestone__c> milestones, Milestone1_Milestone__c currentMilestone){
        for(Milestone1_Milestone__c currentSubMilestone : milestones)
        {
            if(currentSubMilestone.Parent_Milestone__c == currentMilestone.ImportID__c)
            {
                currentSubMilestone.Parent_Milestone__c = currentMilestone.Id;
                currentSubMilestone.Project__c = currentMilestone.Project__c;
            }
        }
    }
    
    global Boolean matchTaskToMilestone(List<Milestone1_Milestone__c> milestones, Milestone1_Task__c currentTask){
        for(Milestone1_Milestone__c currentMilestone : milestones){
            if(currentTask.Project_Milestone__c == currentMilestone.ImportID__c){
                currentTask.Project_Milestone__c = currentMilestone.Id;
                return true;
            }
        }
        return false;
    }
    global void matchTaskToTask(Milestone1_Task__c currentTask){
        for(Milestone1_Task__c task:subTasks){
            if(task.Predecessor_Task_Import_Id__c==currentTask.ImportID__c){
                task.Predecessor_Task__c=currentTask.id;
            }
        }
    }
    
    global void parseProject(Xmlstreamreader reader) {
        
        while (reader.hasNext()) {
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                reader.next();
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE) {
                reader.next();
                parseMilestone(reader,null);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                project.ImportId__c = getDecodedString(reader);
                system.debug(LoggingLevel.warn, 'Import ID == ' + project.ImportID__c);
                if (project.ImportId__c.length() > 15) {
                    project.ImportId__c = project.ImportId__c.substring(0,15);
                }
                if (project.ImportId__c.length() != 15) {
                    throw new Milestone1_Import_Exception('Invalid Import ID (length must be 15)');
                }
            }
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_PROJECT){
                break;
            }
            
            if(reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Duration') {
                reader.next();
                String val = getDecodedString(reader);
                if(val != null) {
                    this.oldProjectDuration = Integer.valueOf(val);
                }
                
                //Difference between New and Old durations
                if(this.oldProjectDuration != null && this.newProjectDuration != null && this.oldProjectDuration != 0)
                    proportionaldurationsDifference = Double.valueOf(this.newProjectDuration)/Double.valueOf(this.oldProjectDuration);
                else
                    proportionaldurationsDifference = 1;
                
                System.debug('#### oldProjectDuration: ' + oldProjectDuration);
                System.debug('#### proportionaldurationsDifference: ' + proportionaldurationsDifference);
            }
            
            if(reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'StartDate') {
                reader.next();
                String val = getDecodedString(reader);
                if(!String.isBlank(val)) {
                    oldProjectStartDate = Date.valueOf(val);
                    /*
                    if(oldProjectStartDate != null) {
                        daysBetweenStartDates = oldProjectStartDate.daysBetween(Date.today());
                        System.debug('#### daysBetweenStartDates: ' + daysBetweenStartDates);   
                    }*/
                }        
            }
            reader.next();
        }
    }
    
    global void parseMilestone(Xmlstreamreader reader, Milestone1_Milestone__c parentMilestone)
    {
        Date projectMAD = getProjectMAD(project);
        Milestone1_Milestone__c currentMilestone = new Milestone1_Milestone__c();
        if(parentMilestone != null)
        {
            currentMilestone.Parent_Milestone__c = parentMilestone.ImportID__c;
        }
        
        currentMilestone.Project__c = project.ImportID__c;
        
        while (reader.hasNext()){
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                currentMilestone.ImportID__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                reader.next();
                currentMilestone.Name = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                currentMilestone.Description__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Predecessor_Milestone__c'){
                reader.next();
                currentMilestone.Predecessor_Milestone__c =getDecodedString(reader);
                
            }
            
            /*
            // Nazim - Fields used to calculate new Start and End Dates
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'RIC_Mile_Duration_Value__c') {
                reader.next();
                currentMilestone.RIC_Mile_Duration_Value__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'RIC_Mile_Start_Diff_Value__c') {
                reader.next();
                currentMilestone.RIC_Mile_Start_Diff_Value__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'RIC_ReEvaluate_WorkFlow_Value__c') {
                reader.next();
                currentMilestone.RIC_ReEvaluate_WorkFlow_Value__c  = getDecodedString(reader);
            }
            
            // end added Nazim */
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'RIC_Mile_Duration_Value__c') {
                reader.next();
                String val = getDecodedString(reader);
                newTaskDuration = 0;
                if(!String.isBlank(val) && proportionaldurationsDifference != null)
                    newTaskDuration = Math.round(proportionaldurationsDifference * Integer.valueOf(val));
                
                currentMilestone.RIC_Mile_Duration_Value__c = String.valueOf(newTaskDuration);
            }
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Kickoff__c'){
                reader.next();
                String val=getDecodedString(reader);
                if(val == null || val == 'null')
                    val= '';
                
                Date kickOffDate = Date.valueOf(val);
                Integer daysProjectOldKickoff = Math.round(oldProjectStartDate.daysBetween(kickOffDate) * proportionaldurationsDifference);
                kickOffDate = Date.Today().addDays(daysProjectOldKickoff);
                
                currentMilestone.Kickoff__c = kickOffDate;
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Deadline__c'){
                reader.next();
                String val = getDecodedString(reader);
                if(String.isBlank(val))
                    val= '';
                
                Date deadlineDate = date.valueOf(val);
                currentMilestone.Deadline__c = currentMilestone.Kickoff__c.addDays(newTaskDuration);
                
                if(currentMilestone.Kickoff__c.daysBetween(currentMilestone.Deadline__c) == 0)
                    currentMilestone.Deadline__c = currentMilestone.Kickoff__c.addDays(1);
                
                //Si la date est > MAD, mettre la date MAD
                if(currentMilestone.Deadline__c > projectMAD)
                    currentMilestone.Deadline__c = projectMAD;
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'LastTask'){
                reader.next();
                String val = getDecodedString(reader);
                if(String.isBlank(val))
                    val= '';
                
                if(val.equals('true'))
                    currentMilestone.Deadline__c = projectMAD;
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE) {
                reader.next();
                parseMilestone(reader,currentMilestone);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TASK) {
                reader.next();
                parseTask(reader,currentMilestone);
            }
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE)
            {
                break;
            }
            reader.next();
        }
        if(parentMilestone != null)
        {
            subMilestones.add(currentMilestone);
        }else
        {
            milestones.add(currentMilestone);
        }
    }
    
    global void parseTask(XMLStreamreader reader, Milestone1_Milestone__c currentMilestone){
        
        Date projectMAD = getProjectMAD(project);
        Milestone1_Task__c currentTask = new Milestone1_Task__c();
        currentTask.Project_Milestone__c = currentMilestone.ImportID__c;
        while(reader.hasNext())
        {
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                currentTask.ImportID__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                currentTask.Description__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                reader.next();
                currentTask.Name = getDecodedString(reader);
                if(currentTask.Name == null){system.debug('Name is NULL '); currentTask.Name = 'Name Blank';}
            }
            // Nazim - Will perhaps remove Predecessor Task in the future ??
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Predecessor_Task__c') {
                reader.next();
                currentTask.Predecessor_Task__c=getDecodedString(reader);
            }
            
            /*
            // Nazim - Fields used to calculate new Start and End Dates
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'RIC_Task_Duration_Value__c') {
                reader.next();
                currentTask.RIC_Task_Duration_Value__c = getDecodedString(reader);
            }*/
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Assigned_To__c') {
                reader.next();
                currentTask.Assigned_To__c=getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'RIC_Task_Start_Diff_Value__c') {
                reader.next();
                currentTask.RIC_Task_Start_Diff_Value__c = getDecodedString(reader);
            }
            //TMA JSA 198
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'RIC_Notifier_RCTA__c') {
                reader.next();
                currentTask.RIC_Notifier_RCTA__c = Boolean.valueOf(getDecodedString(reader));
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'RIC_MAD_reelle__c') {
                reader.next();
                currentTask.RIC_MAD_reelle__c = Boolean.valueOf(getDecodedString(reader));
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'RIC_notif_coord__c') {
                reader.next();
                currentTask.RIC_notif_coord__c = Boolean.valueOf(getDecodedString(reader));
            }
            
            //End TMA 198
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'RIC_ReEvaluate_WorkFlow_Value__c') {
                reader.next();
                currentTask.RIC_ReEvaluate_WorkFlow_Value__c  = getDecodedString(reader);
            }
            
            // end Nazim 
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'RIC_Task_Duration_Value__c') {
                reader.next();
                String val = getDecodedString(reader);
                newTaskDuration = 0;
                if(!String.isBlank(val) && proportionaldurationsDifference != null)
                    newTaskDuration = Math.round(proportionaldurationsDifference * Integer.valueOf(val));
                
                currentTask.RIC_Task_Duration_Value__c = String.valueOf(newTaskDuration);
            }
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Project_Milestone__c') {
                reader.next();
                currentTask.Project_Milestone__c=getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Start_Date__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null')
                    val='';
                
                Date startDate = Date.valueOf(val);
                Integer daysProjectOldKickoff = Math.round(oldProjectStartDate.daysBetween(startDate) * proportionaldurationsDifference);
                startDate = Date.Today().addDays(daysProjectOldKickoff);
                
                currentTask.Start_Date__c = startDate;
            }
            if(reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Due_Date__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null')
                    val='';
                
                Date dueDate = date.valueOf(val);
                /*if(durationsDifference != null)
                    dueDate = dueDate.addDays(durationsDifference);
                if(daysBetweenStartDates != null)
                    dueDate = dueDate.addDays(daysBetweenStartDates);*/
                
                currentTask.Due_Date__c = currentTask.Start_Date__c.addDays(newTaskDuration);
                if(currentTask.Start_Date__c.daysBetween(currentTask.Due_Date__c) == 0)
                    currentTask.Due_Date__c = currentTask.Start_Date__c.addDays(1);
                
                //Si la date est > MAD, mettre la date MAD
                if(currentTask.Due_Date__c > projectMAD)
                    currentTask.Due_Date__c = projectMAD;
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'LastTask'){
                reader.next();
                String val = getDecodedString(reader);
                if(String.isBlank(val))
                    val= '';
                
                if(val.equals('true'))
                    currentTask.Due_Date__c = projectMAD;
            }
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TASK)
            {
                break;
            }
            reader.next();
        }
        
        if( currentTask.Predecessor_Task__c != null)
        {
            subTasks.add(currentTask);
        }
        tasks.add(currentTask);
    }
    
    
    
    global void parseMeta(Xmlstreamreader reader) {
        while (reader.hasNext()) {
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_VERSION) {
                reader.next();
                metadata.ExportVersion = getDecodedString(reader);
                if(metadata.ExportVersion != Milestone1_Constants.XML_EXPORT_VERSION_VAL)
                {
                    throw new Milestone1_Import_Exception(system.label.Milestone1_InvalidVersion + metadata.ExportVersion + system.label.Milestone1_OrganizationsVersion + Milestone1_Constants.XML_EXPORT_VERSION_VAL + system.label.Milestone1_ProjectsMustBeExported);
                }
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_PACKAGE) {
                reader.next();
                metadata.ExportPackage = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_AUTHOR) {
                reader.next();
                metadata.ExportAuthor = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_ORG) {
                reader.next();
                metadata.ExportOrganization = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_DATE) {
                reader.next();
                metadata.ExportCreateDate = DateTime.valueOf(getDecodedString(reader));
            }
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_META)
            {
                break;
            }
            reader.next();
        }
    }
    
    global String getDecodedString(Xmlstreamreader reader) {
        return EncodingUtil.urlDecode(reader.getText(), 'UTF-8').trim();
    }
    
    global Date getProjectMAD(Milestone1_Project__c project) {
        if(project.RIC_MAD_Date_Approved__c != null) {
            return project.RIC_MAD_Date_Approved__c;
        }
        else if(project.RIC_MAD_Date_Real__c != null) {
            return project.RIC_MAD_Date_Real__c;
        }
        else
            return project.RIC_MAD_Date__c;
    }
}