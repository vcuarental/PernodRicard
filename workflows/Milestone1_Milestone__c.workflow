<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>RIC_Blank_4_ReEvaluate</fullName>
        <field>RIC_ReEvaluate_WorkFlow_Value__c</field>
        <name>RIC_Blank_4_ReEvaluate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RIC_Update_Mile_Duration_Value</fullName>
        <description>Field update on RIC_Mile_Duration_Value by taking the value of the formula field RIC_Mile_Duration_Formula</description>
        <field>RIC_Mile_Duration_Value__c</field>
        <formula>TEXT(  RIC_Mile_Duration_Formula__c )</formula>
        <name>RIC_Update_Mile_Duration_Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RIC_Update_Mile_EndDate</fullName>
        <description>Field update that updates the End Date of a Milestone by taking the start date of the Milestone and Adding the number of days from the field RIC_Mile_Duration_Value</description>
        <field>Deadline__c</field>
        <formula>Kickoff__c  +  VALUE( RIC_Mile_Duration_Value__c )</formula>
        <name>RIC_Update_Mile_EndDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RIC_Update_Mile_End_Date</fullName>
        <description>Field update on End Date of a Milestone</description>
        <field>Deadline__c</field>
        <formula>Kickoff__c  +  VALUE( RIC_Mile_Duration_Value__c )</formula>
        <name>RIC_Update_Mile_End_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RIC_Update_Mile_StartDate</fullName>
        <description>Field update that takes the Start Date of a project and adds the number of days difference which is found on the field RIC_Mile_Start_Diff_Value</description>
        <field>Kickoff__c</field>
        <formula>Project__r.RIC_Request_Date__c  +  VALUE( RIC_Mile_Start_Diff_Value__c )</formula>
        <name>RIC_Update_Mile_StartDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RIC_Update_Mile_Start_Date</fullName>
        <description>Updates the Start Date of a Milestone</description>
        <field>Kickoff__c</field>
        <formula>Project__r.RIC_Request_Date__c  +  VALUE( RIC_Mile_Start_Diff_Value__c )</formula>
        <name>RIC_Update_Mile_Start_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RIC_Update_Mile_Start_Diff_Value</fullName>
        <description>Updates the field RIC_Mile_Start_Diff_Value with the value of the formula field RIC_Mile_Start_Diff_Formula</description>
        <field>RIC_Mile_Start_Diff_Value__c</field>
        <formula>TEXT( RIC_Mile_Start_Diff_Formula__c )</formula>
        <name>RIC_Update_Mile_Start_Diff_Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RIC_Update_ReEvaluate</fullName>
        <field>RIC_ReEvaluate_WorkFlow_Value__c</field>
        <formula>&quot;Update&quot;</formula>
        <name>RIC_Update_ReEvaluate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>RIC_Copy_Formula_To_Value</fullName>
        <actions>
            <name>RIC_Update_Mile_Duration_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RIC_Update_Mile_Start_Diff_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Takes the values from RIC_Mile_Duration_Formula and RIC_Mile_Start_Diff_Formula and gives it to their corresponding Number Fields</description>
        <formula>OR(ISCHANGED( Kickoff__c ),ISCHANGED( Deadline__c ),  RIC_ReEvaluate_WorkFlow_Value__c = &quot;No&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
