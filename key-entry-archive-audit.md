# Authorized Archive Key-Entry UI Audit

This note records source-only findings from `/home/ubuntu/authorized-lua-audit/ALL LUA DEC 4.5 BGMI`. No existing loader, panel, API, transport, device-binding, or validation code was modified during this audit.

## Confirmed candidates

| Candidate | Confirmed capability | Why it cannot yet be used directly for a license key |
|---|---|---|
| `Home_Input_Popups_UIBP.lua` | Has `Text_Name`, `OnTextCommitted`, `Button_OK`, `Button_Cancel`, and invokes a callback with the entered text. It is opened through `UIManager.ShowUI(UIManager.UI_Config.Home_Input_Popups_UIBP, ...)`. The UI registration is in `home_ui_configs.lua`. | It hard-limits input to 12 characters and applies `StringUtil.CheckName`, which may normalize or reject valid license-key characters. A username-prefixed key exceeds that limit and must remain unchanged. |
| `guest_bind_password_set.lua` | Has editable text boxes, confirmation, and `GetText()` handling. | It accepts digits only and enforces the game password length, so it would corrupt or reject a license key. |
| `login_phone_mail.lua` | Has editable fields and confirmation controls. | It is an account-login UI with account/password validation, network events, and account-specific state; it is not a standalone generic key dialog. |
| `login_msg_box_common.lua` | Has OK and Cancel buttons. | It is display-only and has no editable text control. |
| `UGC_ModShare_Popup_UIBP.lua` | Has one editable field, a 128-character limit, and an OK button. Its input handling only removes carriage-return and line-feed characters. | Its constructor requires UGC share data and its confirm action invokes the UGC chat pre-filter/send path rather than a generic caller callback. Reusing it for keys would require modifying its existing game-specific behavior. |

## Confirmed UI contract

The archive uses popup classes that inherit from `client.slua_ui_framework.base`. These classes bind editable-widget events with `AddControlEventByControl(...)` and are opened through `UIManager.ShowUI(...)` using registered `UIManager.UI_Config` entries. The current standalone loader uses only the documented message-box path and does not itself expose such a generic editable-widget creation API.

## Current conclusion

The supplied archive confirms that editable text fields and OK callbacks exist in the host UI framework. It does not identify a generic registered popup that both accepts a full license key without normalization and returns that key to a standalone caller. The closest candidate is tied to UGC/chat behavior, while the clean callback candidate is name-normalized and limited to 12 characters. Any integration must be presented to the user for approval before modifying verified working code.
