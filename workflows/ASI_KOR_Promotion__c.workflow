<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_KOR_PmtUpdateColorReference</fullName>
        <description>Update color reference rich text</description>
        <field>ASI_KOR_Color_Reference__c</field>
        <formula>&apos;&lt;span style=&quot;display:inline-block;height:14px;padding:0 2px;color: &apos; &amp; TEXT( ASI_KOR_Text_Color__c ) &amp; &apos;;background-color: &apos; &amp; TEXT( ASI_KOR_Background_Color__c ) &amp; &apos;;&quot;&gt;&apos; &amp; ASI_KOR_Promotion_Name__c &amp; &apos;&lt;/span&gt;&apos;</formula>
        <name>ASI_KOR_PmtUpdateColorReference</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_KOR_PmtUpdateColorReference</fullName>
        <actions>
            <name>ASI_KOR_PmtUpdateColorReference</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( ASI_KOR_Background_Color__c ) || ISCHANGED( ASI_KOR_Text_Color__c ) || ISCHANGED( ASI_KOR_Promotion_Name__c ) || ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
