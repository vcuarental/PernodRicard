<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_CN_CustomerGroup_Update_GRC</fullName>
        <field>ASI_CRM_Greater_Region_Code__c</field>
        <formula>if( INCLUDES( ASI_CRM_Greater_Region__c , &apos;大中区 Greater Central&apos;) , &apos;GC,&apos;, &apos;&apos;) + 
if( INCLUDES( ASI_CRM_Greater_Region__c , &apos;大东区 Greater East&apos;) , &apos;GE,&apos;, &apos;&apos;) + 
if( INCLUDES( ASI_CRM_Greater_Region__c , &apos;大北区 Greater North&apos;) , &apos;GN,&apos;, &apos;&apos;) + 
if( INCLUDES( ASI_CRM_Greater_Region__c , &apos;大西北区 Greater Northwest&apos;) , &apos;GNW,&apos;, &apos;&apos;) + 
if( INCLUDES( ASI_CRM_Greater_Region__c , &apos;大南区 Greater South&apos;) , &apos;GS,&apos;, &apos;&apos;)</formula>
        <name>CN CustomerGroup Update GRC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_UpdateJDESynded</fullName>
        <description>Update JDE Synced to FALSE to trigger ETL Update</description>
        <field>ASI_CRM_JDE_Synced__c</field>
        <literalValue>0</literalValue>
        <name>Update JDE Synced</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_CN_CustomerGroup_GRC</fullName>
        <actions>
            <name>ASI_CRM_CN_CustomerGroup_Update_GRC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Customer_Group__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN National Group</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_JP_UPDATE_CNAME</fullName>
        <actions>
            <name>ASI_CRM_JP_UpdateJDESynded</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update JDE Status</description>
        <formula>ISCHANGED(Name)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
