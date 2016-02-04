class StagingPercentagePolicy < Struct.new(:user, :staging_percentage)
	POLICY_CONTROLLER = StagingPercentagesController
	include PolicyModule
	include HeadlessPolicyModule
end