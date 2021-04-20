<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>RIC_Amb_Update_Adresse_Activations</fullName>
        <field>RIC_Amb_Adresse_client__c</field>
        <formula>RIC_Amb_Code_client_Ricard_GEO__r.RIC_Amb_Adresse_client_Source_ELITE__c</formula>
        <name>Update Adresse Activations</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RIC_Amb_Update_Code_Postal_Activations</fullName>
        <field>RIC_Amb_Code_Postal__c</field>
        <formula>RIC_Amb_Code_client_Ricard_GEO__r.RIC_Amb_Code_Postal_Source_ELITE__c</formula>
        <name>Update Code Postal Activations</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RIC_Amb_Update_Email_Activations</fullName>
        <field>RIC_Amb_Email_Activation__c</field>
        <formula>RIC_Amb_Code_client_Ricard_GEO__r.RIC_Amb_Email_Source_ELITE__c</formula>
        <name>Update Email Activations</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RIC_Amb_Update_Ville_Activations</fullName>
        <field>RIC_Amb_Ville__c</field>
        <formula>RIC_Amb_Code_client_Ricard_GEO__r.RIC_Amb_Ville_Source_ELITE__c</formula>
        <name>Update Ville Activations</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>RIC_Amb_Update_Adresse_ELITE</fullName>
        <actions>
            <name>RIC_Amb_Update_Adresse_Activations</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( ISBLANK(RIC_Amb_Adresse_client__c) || NOT(ISNULL(RIC_Amb_Adresse_client__c)) ) &amp;&amp; NOT(ISBLANK ( RIC_Amb_Code_client_Ricard_GEO__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RIC_Amb_Update_Code_Postal_ELITE</fullName>
        <actions>
            <name>RIC_Amb_Update_Code_Postal_Activations</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( ISBLANK(RIC_Amb_Code_Postal__c) || NOT(ISNULL(RIC_Amb_Code_Postal__c)) ) &amp;&amp; NOT(ISBLANK ( RIC_Amb_Code_client_Ricard_GEO__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RIC_Amb_Update_Ville_ELITE</fullName>
        <actions>
            <name>RIC_Amb_Update_Ville_Activations</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(  ISBLANK(RIC_Amb_Ville__c)  ||  NOT(ISNULL(RIC_Amb_Ville__c))   ) &amp;&amp; NOT(ISBLANK ( RIC_Amb_Code_client_Ricard_GEO__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
