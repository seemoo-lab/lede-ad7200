# Figure out the containing dir of this Makefile
OVERLAY_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Declare custom installation commands
define custom_prepare_commands
		@echo "Installing custom patches from $(OVERLAY_DIR)"
		$(call PatchDir,$(PKG_BUILD_DIR),$(OVERLAY_DIR)/mac80211/patches,)
		$(if $(QUILT),touch $(PKG_BUILD_DIR)/.quilt_used)

		@echo "Overwriting wil6210 driver from custom source in $(OVERLAY_DIR)"
		$(CP) $(OVERLAY_DIR)/mac80211/wil6210/* $(PKG_BUILD_DIR)/drivers/net/wireless/ath/wil6210/

endef

# Append custom commands to install recipe,
# and make sure to include a newline to avoid syntax error
Build/Prepare += $(newline)$(custom_prepare_commands)
