<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AME_project_cloud_Project_Name_Update</fullName>
        <field>Name</field>
        <formula>project_cloud__Ticket__r.project_cloud__Ticket_Name__c</formula>
        <name>AME_project_cloud_Project_Name_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Status_Completed</fullName>
        <field>AME_project_cloud_Status__c</field>
        <literalValue>Completed</literalValue>
        <name>AME_project_cloud_Status_Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Status_In_Progress</fullName>
        <field>AME_project_cloud_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>AME_project_cloud_Status_In_Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Status_In_Progress_Lat</fullName>
        <field>AME_project_cloud_Status__c</field>
        <literalValue>In Progress - Late</literalValue>
        <name>AME_project_cloud_Status_In_Progress_Lat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Status_Not_Started</fullName>
        <field>AME_project_cloud_Status__c</field>
        <literalValue>Not Started</literalValue>
        <name>AME_project_cloud_Status_Not_Started</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Status_Not_Started_Lat</fullName>
        <field>AME_project_cloud_Status__c</field>
        <literalValue>Not Started - Late</literalValue>
        <name>AME_project_cloud_Status_Not_Started_Lat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AME_project_cloud_Project_Name_Update</fullName>
        <actions>
            <name>AME_project_cloud_Project_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Project__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Configuration,Emergency</value>
        </criteriaItems>
        <description>This workflow rule automatically sets the Project Name to equal the Ticket Name for Configuration and Emergency projects.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AME_project_cloud_Status_Completed</fullName>
        <actions>
            <name>AME_project_cloud_Status_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Project__c.project_cloud__Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>project_cloud__Project__c.AME_project_cloud_Status__c</field>
            <operation>notEqual</operation>
            <value>On Hold,Canceled,Post Go Live Review</value>
        </criteriaItems>
        <description>This workflow rule updates the manual Status field to Completed when Project Status equals In Completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AME_project_cloud_Status_Not_In_Progress</fullName>
        <actions>
            <name>AME_project_cloud_Status_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Project__c.project_cloud__Status__c</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>project_cloud__Project__c.AME_project_cloud_Status__c</field>
            <operation>notEqual</operation>
            <value>On Hold,Canceled,Post Go Live Review</value>
        </criteriaItems>
        <description>This workflow rule updates the manual Status field to In Progress when Project Status equals In Progress</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AME_project_cloud_Status_Not_In_Progress_Late</fullName>
        <actions>
            <name>AME_project_cloud_Status_In_Progress_Lat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Project__c.project_cloud__Status__c</field>
            <operation>equals</operation>
            <value>In Progress - Late</value>
        </criteriaItems>
        <criteriaItems>
            <field>project_cloud__Project__c.AME_project_cloud_Status__c</field>
            <operation>notEqual</operation>
            <value>On Hold,Canceled,Post Go Live Review</value>
        </criteriaItems>
        <description>This workflow rule updates the manual Status field to In Progress - Late when Project Status equals In Progress - Late</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AME_project_cloud_Status_Not_Started</fullName>
        <actions>
            <name>AME_project_cloud_Status_Not_Started</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Project__c.project_cloud__Status__c</field>
            <operation>equals</operation>
            <value>Not Started</value>
        </criteriaItems>
        <criteriaItems>
            <field>project_cloud__Project__c.AME_project_cloud_Status__c</field>
            <operation>notEqual</operation>
            <value>On Hold,Canceled,Post Go Live Review</value>
        </criteriaItems>
        <description>This workflow rule updates the manual Status field to Not Started when Project Status equals Not Started</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AME_project_cloud_Status_Not_Started_Late</fullName>
        <actions>
            <name>AME_project_cloud_Status_Not_Started_Lat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Project__c.project_cloud__Status__c</field>
            <operation>equals</operation>
            <value>Not Started - Late</value>
        </criteriaItems>
        <criteriaItems>
            <field>project_cloud__Project__c.AME_project_cloud_Status__c</field>
            <operation>notEqual</operation>
            <value>On Hold,Canceled,Post Go Live Review</value>
        </criteriaItems>
        <description>This workflow rule updates the manual Status field to Not Started - Late when Project Status equals Not Started - Late</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
