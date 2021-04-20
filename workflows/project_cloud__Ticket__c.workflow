<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AME_project_cloud_Ticket_Update_Config</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Demand_Configuration</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>AME_project_cloud_Ticket_Update_Config</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Ticket_Update_Emergenc</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Demand_Emergency</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>AME_project_cloud_Ticket_Update_Emergenc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Ticket_Update_Minor_En</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Demand_Minor_Enhancement</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>AME_project_cloud_Ticket_Update_Minor_En</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Ticket_Update_Project</fullName>
        <field>RecordTypeId</field>
        <lookupValue>AME_project_cloud_Demand</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>AME_project_cloud_Ticket_Update_Project</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Ticket_Update_Release</fullName>
        <field>RecordTypeId</field>
        <lookupValue>AME_project_cloud_Demand_Release</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>AME_project_cloud_Ticket_Update_Release</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Update_Benefits</fullName>
        <field>AME_project_cloud_Benefits__c</field>
        <formula>AME_project_cloud_Incident__r.AME_Benefits__c</formula>
        <name>AME_project_cloud_Update_Benefits</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Update_Current_Situati</fullName>
        <field>AME_project_cloud_Current_Situation__c</field>
        <formula>AME_project_cloud_Incident__r.AME_Current_Situation__c</formula>
        <name>AME_project_cloud_Update_Current_Situati</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Update_Demand_Descript</fullName>
        <field>AME_project_cloud_Demand_Description__c</field>
        <formula>AME_project_cloud_Incident__r.BMCServiceDesk__incidentDescription__c</formula>
        <name>AME_project_cloud_Update_Demand_Descript</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Update_Description</fullName>
        <field>project_cloud__Description__c</field>
        <formula>AME_project_cloud_Demand_Description__c</formula>
        <name>AME_project_cloud_Update_Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Update_Impact</fullName>
        <field>AME_project_cloud_Impact_Incident__c</field>
        <formula>AME_project_cloud_Incident__r.AME_Impact__c</formula>
        <name>AME_project_cloud_Update_Impact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AME_project_cloud_Update_Ticket_Name</fullName>
        <field>project_cloud__Ticket_Name__c</field>
        <formula>AME_project_cloud_Incident__r.Summary__c</formula>
        <name>AME_project_cloud_Update_Ticket_Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AME_project_cloud_Incident_to_Ticket_Updates</fullName>
        <actions>
            <name>AME_project_cloud_Update_Benefits</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AME_project_cloud_Update_Current_Situati</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AME_project_cloud_Update_Demand_Descript</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AME_project_cloud_Update_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AME_project_cloud_Update_Impact</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AME_project_cloud_Update_Ticket_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Ticket__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Demand,Demand (Release),Demand (Configuration),Demand (Emergency)</value>
        </criteriaItems>
        <criteriaItems>
            <field>project_cloud__Ticket__c.AME_project_cloud_Impact_Incident__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule updates the name, description, demand description, benefits, current situation, and impact fields from the incident to the ticket when the ticket is created and/or edited.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AME_project_cloud_Ticket_Update_Config</fullName>
        <actions>
            <name>AME_project_cloud_Ticket_Update_Config</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Ticket__c.AME_project_cloud_Portfolio_Type__c</field>
            <operation>equals</operation>
            <value>Configuration</value>
        </criteriaItems>
        <description>This work flow rule will updated the record type of a ticket to Demand (Configuration) when Portfolio Type equals Configuration.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AME_project_cloud_Ticket_Update_Emergency</fullName>
        <actions>
            <name>AME_project_cloud_Ticket_Update_Emergenc</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Ticket__c.AME_project_cloud_Portfolio_Type__c</field>
            <operation>equals</operation>
            <value>Emergency</value>
        </criteriaItems>
        <description>This work flow rule will updated the record type of a ticket to Demand (Emergency) when Portfolio Type equals Emergency.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AME_project_cloud_Ticket_Update_Minor_Enhancement</fullName>
        <actions>
            <name>AME_project_cloud_Ticket_Update_Minor_En</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Ticket__c.AME_project_cloud_Portfolio_Type__c</field>
            <operation>equals</operation>
            <value>Minor Enhancement</value>
        </criteriaItems>
        <description>This work flow rule will updated the record type of a ticket to Demand (Minor Enhancement) when Portfolio Type equals Minor Enhancement.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AME_project_cloud_Ticket_Update_Project</fullName>
        <actions>
            <name>AME_project_cloud_Ticket_Update_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Ticket__c.AME_project_cloud_Portfolio_Type__c</field>
            <operation>equals</operation>
            <value>Project</value>
        </criteriaItems>
        <description>This work flow rule will updated the record type of a ticket to Demand when Portfolio Type equals Project.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AME_project_cloud_Ticket_Update_Release</fullName>
        <actions>
            <name>AME_project_cloud_Ticket_Update_Release</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>project_cloud__Ticket__c.AME_project_cloud_Portfolio_Type__c</field>
            <operation>equals</operation>
            <value>Release</value>
        </criteriaItems>
        <description>This work flow rule will updated the record type of a ticket to Demand (Release) when Portfolio Type equals Release.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
