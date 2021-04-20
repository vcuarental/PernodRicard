<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Ad_hoc_Trade_Promotion</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Ad_hoc_Trade_Promotion</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG Ad-hoc Trade Promotion</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Ad_hoc_Trade_Promotion_RO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Ad_hoc_Trade_Promotion_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG Ad-hoc Trade Promotion (RO)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_SYS_Allow_Submit_Approval_F</fullName>
        <field>ASI_CRM_SYS_Allow_Submit_Approval__c</field>
        <literalValue>0</literalValue>
        <name>ASI CRM SG SYS Allow Submit Approval F</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Approved</fullName>
        <field>ASI_HK_CRM_Status__c</field>
        <formula>&quot;Approved&quot;</formula>
        <name>ASI CRM SG Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Draft</fullName>
        <field>ASI_HK_CRM_Status__c</field>
        <formula>&quot;Draft&quot;</formula>
        <name>ASI CRM SG Status Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Rejected</fullName>
        <field>ASI_HK_CRM_Status__c</field>
        <formula>&quot;Rejected&quot;</formula>
        <name>ASI CRM SG Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Submitted</fullName>
        <field>ASI_HK_CRM_Status__c</field>
        <formula>&quot;Submitted&quot;</formula>
        <name>ASI CRM SG Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_PmtUpdateColorReference</fullName>
        <description>Update the Promotion color preview field</description>
        <field>ASI_HK_CRM_Color_Reference__c</field>
        <formula>&apos;&lt;span style=&quot;display:inline-block;height:14px;padding:0 2px;color: &apos; &amp; TEXT( ASI_HK_CRM_Text_Color__c ) &amp; &apos;;background-color: &apos; &amp; TEXT( ASI_HK_CRM_Background_Color__c ) &amp; &apos;;&quot;&gt;&apos; &amp; ASI_HK_CRM_Promotion_Name__c &amp; &apos;&lt;/span&gt;&apos;</formula>
        <name>ASI_HK_CRM_PmtUpdateColorReference</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_SG_SetPromotionToDraft</fullName>
        <actions>
            <name>ASI_CRM_SG_Ad_hoc_Trade_Promotion</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Promotion__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Ad-hoc Trade Promotion (Read-Only)</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_HK_CRM_Promotion__c.ASI_HK_CRM_Status__c</field>
            <operation>equals</operation>
            <value>Draft</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_HK_CRM_PmtUpdateColorReference</fullName>
        <actions>
            <name>ASI_HK_CRM_PmtUpdateColorReference</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the preview HTML according to selected color</description>
        <formula>ISCHANGED( ASI_HK_CRM_Background_Color__c ) || ISCHANGED( ASI_HK_CRM_Text_Color__c ) || ISCHANGED( ASI_HK_CRM_Promotion_Name__c ) || ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
