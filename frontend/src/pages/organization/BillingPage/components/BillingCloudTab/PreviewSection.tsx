import { OrgPermissionCan } from "@app/components/permissions";
import {
  OrgPermissionBillingActions,
  OrgPermissionSubjects,
  useOrganization,
  useSubscription
} from "@app/context";
import { isInfisicalCloud } from "@app/helpers/platform";
import { useCreateCustomerPortalSession, useGetOrgPlanBillingInfo } from "@app/hooks/api";
import { usePopUp } from "@app/hooks/usePopUp";

import { ManagePlansModal } from "./ManagePlansModal";

export const PreviewSection = () => {
  const { currentOrg } = useOrganization();
  const { subscription } = useSubscription();
  const { data, isPending } = useGetOrgPlanBillingInfo(currentOrg?.id ?? "");
  const createCustomerPortalSession = useCreateCustomerPortalSession();

  const { popUp, handlePopUpToggle } = usePopUp(["managePlan"] as const);

  const formatAmount = (amount: number) => {
    const formattedTotal = (Math.floor(amount) / 100).toLocaleString("en-US", {
      style: "currency",
      currency: "USD"
    });

    return formattedTotal;
  };

  const formatDate = (date: number) => {
    const createdDate = new Date(date * 1000);
    const day: number = createdDate.getDate();
    const month: number = createdDate.getMonth() + 1;
    const year: number = createdDate.getFullYear();
    const formattedDate: string = `${day}/${month}/${year}`;

    return formattedDate;
  };

  function formatPlanSlug(slug: string) {
    if (!slug) {
      return "-";
    }
    return slug.replace(/(\b[a-z])/g, (match) => match.toUpperCase()).replace(/-/g, " ");
  }

  return (
    <div>
      {!isPending && subscription && data && (
        <div className="mb-6 flex">
          <div className="mr-4 flex-1 rounded-lg border border-mineshaft-600 bg-mineshaft-900 p-4">
            <p className="mb-2 text-gray-400">Current plan</p>
            <p className="mb-8 text-2xl font-semibold text-mineshaft-50">
              {`${formatPlanSlug(subscription.slug)} ${
                subscription.status === "trialing" ? "(Trial)" : ""
              }`}
            </p>
            {isInfisicalCloud() && (
              <OrgPermissionCan
                I={OrgPermissionBillingActions.ManageBilling}
                a={OrgPermissionSubjects.Billing}
              >
                {(isAllowed) => (
                  <button
                    type="button"
                    onClick={async () => {
                      if (!currentOrg?.id) return;
                      const { url } = await createCustomerPortalSession.mutateAsync(currentOrg.id);
                      window.location.href = url;
                    }}
                    disabled={!isAllowed}
                    className="text-primary"
                  >
                    Manage plan &rarr;
                  </button>
                )}
              </OrgPermissionCan>
            )}
          </div>
          <div className="mr-4 flex-1 rounded-lg border border-mineshaft-600 bg-mineshaft-900 p-4">
            <p className="mb-2 text-gray-400">Price</p>
            <p className="mb-8 text-2xl font-semibold text-mineshaft-50">
              {subscription.status === "trialing"
                ? "$0.00 / month"
                : `${formatAmount(data.amount)} / ${data.interval}`}
            </p>
          </div>
          <div className="flex-1 rounded-lg border border-mineshaft-600 bg-mineshaft-900 p-4">
            <p className="mb-2 text-gray-400">Subscription renews on</p>
            <p className="mb-8 text-2xl font-semibold text-mineshaft-50">
              {data.currentPeriodEnd ? formatDate(data.currentPeriodEnd) : "-"}
            </p>
          </div>
        </div>
      )}
      <ManagePlansModal popUp={popUp} handlePopUpToggle={handlePopUpToggle} />
    </div>
  );
};
