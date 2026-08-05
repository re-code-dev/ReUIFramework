require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"
require "ReUI/core/ReUITooltip"
require "ReUI/managers/ReUIWindowManager"
require "ReUI/managers/ReUIDockManager"
require "ReUI/components/ReUIWindow"
require "ReUI/components/ReUIButton"
require "ReUI/components/ReUIPanel"
require "ReUI/components/ReUILabel"
require "ReUI/components/ReUICard"
require "ReUI/components/ReUIDivider"
require "ReUI/components/ReUIToggleBase"
require "ReUI/components/ReUICheckbox"
require "ReUI/components/ReUISwitch"
require "ReUI/components/ReUIProgressBar"
require "ReUI/components/ReUISlider"
require "ReUI/components/ReUITextBox"
require "ReUI/components/ReUINumberBox"
require "ReUI/components/ReUIImage"
require "ReUI/components/ReUIDropdown"
require "ReUI/components/ReUITabs"
require "ReUI/components/ReUIListView"
require "ReUI/components/ReUITreeView"
require "ReUI/components/ReUIColorPicker"
require "ReUI/components/ReUIPropertyGrid"
require "ReUI/components/ReUIInspector"
require "ReUI/components/ReUIFileBrowser"
require "ReUI/components/ReUIToast"
require "ReUI/managers/ReUIToastManager"
require "ReUI/components/ReUIContextMenu"
require "ReUI/components/ReUIBreadcrumbs"
require "ReUI/components/ReUIPagination"
require "ReUI/components/ReUIAvatar"
require "ReUI/components/ReUISkeletonLoader"
require "ReUI/components/ReUILoadingSpinner"
require "ReUI/layout/ReUISplitPanel"
require "ReUI/components/ReUIMultiSelect"
require "ReUI/components/ReUIDatePicker"
require "ReUI/components/ReUITimePicker"
require "ReUI/components/ReUICommandPalette"
require "ReUI/components/ReUITable"
require "ReUI/components/ReUISearchBox"
require "ReUI/components/ReUIProgressRing"
require "ReUI/components/ReUITimeline"
require "ReUI/components/ReUIBarChart"
require "ReUI/components/ReUIAssetBrowser"
require "ReUI/designer/ReUIDesignNode"
require "ReUI/layout/ReUIContainer"
require "ReUI/layout/ReUIVBox"
require "ReUI/layout/ReUIHBox"
require "ReUI/layout/ReUIScrollContainer"

ReUI = ReUI or {}

ReUI.VERSION = "0.15.0"
ReUI.Theme = ReUITheme
ReUI.Component = ReUIComponent
ReUI.Tooltip = ReUITooltip
ReUI.WindowManager = ReUIWindowManager
ReUI.DockManager = ReUIDockManager
ReUI.Window = ReUIWindow
ReUI.Button = ReUIButton
ReUI.Panel = ReUIPanel
ReUI.Label = ReUILabel
ReUI.Card = ReUICard
ReUI.Divider = ReUIDivider
ReUI.ToggleBase = ReUIToggleBase
ReUI.Checkbox = ReUICheckbox
ReUI.Switch = ReUISwitch
ReUI.ProgressBar = ReUIProgressBar
ReUI.Slider = ReUISlider
ReUI.TextBox = ReUITextBox
ReUI.NumberBox = ReUINumberBox
ReUI.Image = ReUIImage
ReUI.Dropdown = ReUIDropdown
ReUI.Tabs = ReUITabs
ReUI.ListView = ReUIListView
ReUI.TreeView = ReUITreeView
ReUI.ColorPicker = ReUIColorPicker
ReUI.PropertyGrid = ReUIPropertyGrid
ReUI.Inspector = ReUIInspector
ReUI.FileBrowser = ReUIFileBrowser
ReUI.Toast = ReUIToast
ReUI.ToastManager = ReUIToastManager
ReUI.ContextMenu = ReUIContextMenu
ReUI.Breadcrumbs = ReUIBreadcrumbs
ReUI.Pagination = ReUIPagination
ReUI.Avatar = ReUIAvatar
ReUI.SkeletonLoader = ReUISkeletonLoader
ReUI.LoadingSpinner = ReUILoadingSpinner
ReUI.SplitPanel = ReUISplitPanel
ReUI.MultiSelect = ReUIMultiSelect
ReUI.DatePicker = ReUIDatePicker
ReUI.TimePicker = ReUITimePicker
ReUI.CommandPalette = ReUICommandPalette
ReUI.Table = ReUITable
ReUI.SearchBox = ReUISearchBox
ReUI.ProgressRing = ReUIProgressRing
ReUI.Timeline = ReUITimeline
ReUI.BarChart = ReUIBarChart
ReUI.AssetBrowser = ReUIAssetBrowser
ReUI.Container = ReUIContainer
ReUI.VBox = ReUIVBox
ReUI.HBox = ReUIHBox
ReUI.ScrollContainer = ReUIScrollContainer

ReUI.Layout = ReUI.Layout or {}
ReUI.Layout.Container = ReUIContainer
ReUI.Layout.VBox = ReUIVBox
ReUI.Layout.HBox = ReUIHBox
ReUI.Layout.ScrollContainer = ReUIScrollContainer
ReUI.Layout.SplitPanel = ReUISplitPanel

function ReUI.getVersion()
    return ReUI.VERSION
end

function ReUI.clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

function ReUI.lerp(a, b, amount)
    return a + (b - a) * ReUI.clamp(amount, 0, 1)
end
