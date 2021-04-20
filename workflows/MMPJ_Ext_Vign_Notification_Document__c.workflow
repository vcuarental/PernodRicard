<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MMPJ_Ext_Vign_DocumentsFournis</fullName>
        <ccEmails>partners-mmpj@pernod-ricard.com</ccEmails>
        <description>MMPJ_Ext_Vign_DocumentsFournis</description>
        <protected>false</protected>
        <recipients>
            <field>MMPJ_Ext_Vign_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>partners-mmpj@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>MMPJ_Ext_Vign/MMPJ_Ext_Vign_DocumentsFournis</template>
    </alerts>
    <alerts>
        <fullName>MMPJ_Ext_Vign_Questprevrecolte</fullName>
        <description>MMPJ_Ext_Vign_Questprevrecolte</description>
        <protected>false</protected>
        <recipients>
            <field>MMPJ_Ext_Vign_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>partners-mmpj@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>MMPJ_Ext_Vign/MMPJ_Ext_Vign_DocumentsFournis</template>
    </alerts>
    <rules>
        <fullName>MMPJ_Ext_Vign_DocumentsFournis</fullName>
        <actions>
            <name>MMPJ_Ext_Vign_DocumentsFournis</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MMPJ_Ext_Vign_Documents_Fournis__c.MMPJ_Ext_Vign_Type__c</field>
            <operation>equals</operation>
            <value>Déclaration de récolte,Calendrier de Traitement</value>
        </criteriaItems>
        <description>Envoyer un email dès qu&apos;un doc de type déclaration récolte ou calendrier traitement est créé au niveau de l&apos;objet document fourni et que le(s) notification(s) document  rattachée(s) est créée</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MMPJ_Ext_Vign_DocumentsFournisQuestprevrecolte</fullName>
        <actions>
            <name>MMPJ_Ext_Vign_Questprevrecolte</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MMPJ_Ext_Vign_Documents_Fournis__c.MMPJ_Ext_Vign_Type__c</field>
            <operation>equals</operation>
            <value>Questionnaire de prévision récolte</value>
        </criteriaItems>
        <description>Envoyer un email dès qu&apos;un doc de type questionnaire de prévision de récolte</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
