<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_KR_COGS_Update_External_ID</fullName>
        <description>remove --&gt; &quot;  &apos;&amp;&apos; &amp; TEXT(ASI_CRM_KR_Month__c)   &quot;</description>
        <field>ASI_CRM_KR_ExternalID__c</field>
        <formula>CASESAFEID(ASI_CRM_KR_Account__c) &amp; &apos;&amp;&apos; &amp;  CASESAFEID(ASI_CRM_KR_SubBrand__c)&amp; &apos;&amp;&apos; &amp; TEXT(ASI_CRM_KR_Year__c)</formula>
        <name>ASI CRM KR COGS Update External ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_KR_COGSCheckDuplicateRecord</fullName>
        <actions>
            <name>ASI_CRM_KR_COGS_Update_External_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED( ASI_CRM_KR_Account__c) || ISCHANGED( ASI_CRM_KR_SubBrand__c) || ISCHANGED( ASI_CRM_KR_Year__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
