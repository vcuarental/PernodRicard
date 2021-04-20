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
global with sharing class Milestone1_XML_Export_Utility {
    
    private Milestone1_Project__c project;  
    private List<Milestone1_Milestone__c>  milestones;
    private Map<ID,Milestone1_Milestone__c>  milestonesMap;
    private List<Milestone1_Task__c> milestonesTasks;
    private Map<ID,Milestone1_Task__c> milestonesTasksMap;
    private List<Milestone1_Milestone__c>  subMilestones;
    private Map<ID,Milestone1_Milestone__c>  subMilestonesMap;
    private List<Milestone1_Task__c> subMilestonesTasks;
    private Map<ID,Milestone1_Task__c> subMilestonesTasksMap;
    private Date projectMAD;
    
    global Milestone1_XML_Export_Utility()
    {
        milestonesMap = new Map<ID,Milestone1_Milestone__c>();
        milestonesTasksMap = new Map<ID,Milestone1_Task__c>();
        subMilestonesMap= new Map<ID,Milestone1_Milestone__c>();
        subMilestonesTasksMap = new Map<ID,Milestone1_Task__c>();
    }

    global Milestone1_Project__c lookup(ID targetId) {
        //Retrieve the Project 
        Milestone1_Project__c project = [Select m.Kickoff__c,m.Deadline__c, m.RIC_Duree_projet__c, m.RIC_Request_Date__c, m.RIC_Date_debut_Planning__c,
                                         m.Status__c, m.Name, m.Id, m.Description__c, m.RIC_MAD_Date_Approved__c, m.RIC_MAD_Date_Real__c, m.RIC_MAD_Date__c
                                         From Milestone1_Project__c m 
                                         where Id = :targetId limit 1];
    
           
        //Retrieve all the Milestones  
        milestones = [Select m1.Id, m1.Name, m1.Alias__c,m1.Predecessor_Milestone__c, m1.Deadline__c, m1.Kickoff__c, m1.Complete__c,m1.Description__c, 
                      m1.Project__c, m1.RIC_Mile_Duration_Value__c, m1.RIC_Mile_Start_Diff_Value__c, m1.RIC_ReEvaluate_WorkFlow_Value__c
                      From Milestone1_Milestone__c m1 where Project__c = :project.Id and Parent_Milestone__c = null];
      
        for(Milestone1_Milestone__c milestone : milestones)
        {
            milestonesMap.put(milestone.Id,milestone);
        }
        //Retrieve all the Sub-Milestones 
        subMilestones = [Select m1.Id, m1.Name,m1.Predecessor_Milestone__c,m1.Alias__c, m1.Deadline__c, m1.Kickoff__c, m1.Complete__c,m1.Description__c, 
                         m1.Project__c, m1.RIC_Mile_Duration_Value__c, m1.RIC_Mile_Start_Diff_Value__c, m1.RIC_ReEvaluate_WorkFlow_Value__c,
                         Parent_Milestone__c From Milestone1_Milestone__c m1 where Parent_Milestone__c in :milestonesMap.keySet()];
      
            for(Milestone1_Milestone__c subMilestone : subMilestones)
        {
            subMilestonesMap.put(subMilestone.Id,subMilestone);
        }
        //Retrieve all the Milestone Tasks 
        milestonesTasks = [Select m.Id,m.RIC_Notifier_RCTA__c,m.RIC_notif_coord__c,m.RIC_MAD_reelle__c, m.Name, m.Description__c,m.Predecessor_Task__c, m.Estimated_Hours__c, m.Estimated_Expense__c, m.Start_Date__c, m.Due_Date__c, m.Priority__c, m.Project_Milestone__c, m.Complete__c 
                           ,m.RIC_Task_Duration_Value__c,m.RIC_Task_Start_Diff_Value__c, m.RIC_ReEvaluate_WorkFlow_Value__c, m.Assigned_To__c
                           From Milestone1_Task__c m where m.Project_Milestone__c in : milestonesMap.keySet()];
       
            for(Milestone1_Task__c task : milestonesTasks)
        {
            milestonesTasksMap.put(task.Id,task);
        }
        //Retreive all the Sub Miltestone Tasks 
        submilestonesTasks = [Select m.Id, m.Name, m.Description__c,m.Predecessor_Task__c,m.Estimated_Hours__c, m.Estimated_Expense__c,m.Start_Date__c, m.Due_Date__c, m.Priority__c, m.Project_Milestone__c ,m.Complete__c 
                              ,m.RIC_Task_Duration_Value__c,m.RIC_Task_Start_Diff_Value__c, m.RIC_ReEvaluate_WorkFlow_Value__c, m.Assigned_To__c
                              From Milestone1_Task__c m where m.Project_Milestone__c in : subMilestonesMap.keySet()];
     
        
        for(Milestone1_Task__c task : submilestonesTasks)
        {
            subMilestonesTasksMap.put(task.Id,task);
        }
      
        return project;
    }
    
    global String buildProjectXmlString(ID targetId) {
        project = lookup(targetId);
        projectMAD = getProjectMAD(project);
        Xmlstreamwriter out = new Xmlstreamwriter();
        
        out.writeStartDocument(null,Milestone1_Constants.XML_VERSION);
        
        out.writeStartElement(null, Milestone1_Constants.XML_EXPORT, null);
        out.writeStartElement(null, Milestone1_Constants.XML_META, null);
        
        writeElement(out, Milestone1_Constants.XML_EXPORT_PACKAGE, Milestone1_Constants.XML_EXPORT_PACKAGE_VAL);
        writeElement(out, Milestone1_Constants.XML_EXPORT_AUTHOR, UserInfo.getName());
        writeElement(out, Milestone1_Constants.XML_EXPORT_ORG, UserInfo.getOrganizationName());     
        writeElement(out, Milestone1_Constants.XML_EXPORT_DATE, System.now());
        writeElement(out, Milestone1_Constants.XML_EXPORT_VERSION,Milestone1_Constants.XML_EXPORT_VERSION_VAL);
        
        out.writeEndElement();
        
        writeProjectToXML(out,project);

        out.writeEndDocument();
        String ret = out.getXmlString();
        out.close();
        system.debug('Exit <buildXmlString(Milestone1_Project__c target)> in class <Milestone1_XML_Export_Utility> return string == \n ' + ret);
        return ret;
    }

    global void writeProjectToXML(XMLstreamwriter out, Milestone1_Project__c project )
    {
        out.writeStartElement(null, Milestone1_Constants.OBJ_NAME_PROJECT, null);
        writeElement(out,'Id',project.Id);
        writeElement(out,'Status__c', project.Status__c);
        writeElement(out,'Description__c',project.Description__c);
        writeElement(out,'Name', project.Name);
        writeElement(out,'Duration', project.RIC_Duree_projet__c);
        Date projectStartDate = project.RIC_Date_debut_Planning__c != null ? project.RIC_Date_debut_Planning__c : project.RIC_Request_Date__c;
        writeElement(out,'StartDate', projectStartDate);
        
        for(Milestone1_Milestone__c milestone : milestones) {
            writeMilestoneToXML(out,milestone,true);
        }
        out.writeEndElement();  
    }
    
    global void writeMilestoneToXML(XMLstreamwriter out, Milestone1_Milestone__c milestone, Boolean isParentMilestone )
    {
        List<Milestone1_Task__c> tasks;
        if(isParentMilestone)
        {
            tasks = this.milestonesTasks;
        }else
        {
            tasks = this.subMilestonesTasks;
        }
        out.writeStartElement(null, Milestone1_Constants.OBJ_NAME_MILESTONE, null);
        writeElement(out,'Id', milestone.Id);
        writeElement(out,'Description__c',milestone.Description__c);
        writeElement(out,'Name', milestone.Name);
        writeElement(out,'Alias__c',milestone.Alias__c);
        writeElement(out,'RIC_Mile_Duration_Value__c',milestone.RIC_Mile_Duration_Value__c);
        writeElement(out,'RIC_Mile_Start_Diff_Value__c',milestone.RIC_Mile_Start_Diff_Value__c);
        writeElement(out,'RIC_ReEvaluate_WorkFlow_Value__c','Update');
        writeElement(out,'Predecessor_Milestone__c',milestone.Predecessor_Milestone__c);
        writeElement(out,'Kickoff__c',milestone.Kickoff__c);
        writeElement(out,'Deadline__c',milestone.Deadline__c);
        if(milestone.Deadline__c == projectMAD)
            writeElement(out,'LastTask', 'true');
        else
            writeElement(out,'LastTask', 'false');
        
        for(Milestone1_Task__c task : tasks)
        {
            if(task.Project_Milestone__c == milestone.Id)
            {
                writeTaskToXML(out,task);
            }
        }
        for(Milestone1_Milestone__c subMilestone : subMilestones)
        {
            if(isParentMilestone && subMilestone.Parent_Milestone__c == milestone.Id)
            {
                writeMilestoneToXML(out,subMilestone,false);
            }
        }
        out.writeEndElement();  
    }
    
    
    global void writeTaskToXML(XMLstreamwriter out, Milestone1_Task__c task ){
        out.writeStartElement(null, Milestone1_Constants.OBJ_NAME_TASK, null);
        writeElement(out,'Id', task.Id);
        writeElement(out,'Description__c',task.Description__c);
        //TMA JSA 198
         writeElement(out,'RIC_Notifier_RCTA__c',task.RIC_Notifier_RCTA__c);
        writeElement(out,'RIC_MAD_reelle__c',task.RIC_MAD_reelle__c);
        writeElement(out,'RIC_notif_coord__c',task.RIC_notif_coord__c);
        //End TMA 198 
        writeElement(out,'Name',task.Name);
        writeElement(out,'Predecessor_Task__c',task.Predecessor_Task__c);
        writeElement(out,'RIC_Task_Duration_Value__c',task.RIC_Task_Duration_Value__c);
        writeElement(out,'RIC_Task_Start_Diff_Value__c',task.RIC_Task_Start_Diff_Value__c);
        writeElement(out,'Start_Date__c',task.Start_Date__c);
        writeElement(out,'Due_Date__c',task.Due_Date__c);
        writeElement(out,'Project_Milestone__c',task.Project_Milestone__c);
        writeElement(out,'Assigned_To__c',task.Assigned_To__c);
        writeElement(out,'RIC_ReEvaluate_WorkFlow_Value__c','Update');
        if(task.Due_Date__c == projectMAD)
            writeElement(out,'LastTask', 'true');
        else
            writeElement(out,'LastTask', 'false');
        out.writeEndElement();  
    }
    
    global void writeElement(Xmlstreamwriter out, String tag, Object content) {
    if(content != null){
            out.writeStartElement(null, tag, null);
            out.writeCharacters(EncodingUtil.urlEncode(String.valueOf(content), 'UTF-8'));
            out.writeEndElement();
        }  
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