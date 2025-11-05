<#
.SYNOPSIS
    Dev Sentinel Windows 通知脚本

.DESCRIPTION
    用于在 Windows 环境或 WSL 环境中发送 Windows 桌面通知

.PARAMETER Message
    通知的内容文本

.PARAMETER Title
    通知的标题

.EXAMPLE
    # Windows 环境直接调用
    .\notify.ps1 "这是一条消息" "Dev Sentinel"

.EXAMPLE
    # WSL 环境调用 Windows PowerShell
    /mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass -File notify.ps1 "这是一条消息" "Dev Sentinel"

.NOTES
    文件编码必须为 UTF-8 with BOM
    Author: Jerry
    Version: 1.0.0
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Message = "Dev Sentinel 通知",

    [Parameter(Mandatory=$false)]
    [string]$Title = "Dev Sentinel"
)

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
$toastXml = [Windows.Data.Xml.Dom.XmlDocument]::New()
$toastXml.LoadXml($template.GetXml())

$textNodes = @($toastXml.GetElementsByTagName('text'))
if ($textNodes.Count -ge 2) {
    $textNodes[0].AppendChild($toastXml.CreateTextNode($Title)) | Out-Null
    $textNodes[1].AppendChild($toastXml.CreateTextNode($Message)) | Out-Null
}

$toast = [Windows.UI.Notifications.ToastNotification]::New($toastXml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Dev Sentinel').Show($toast)
