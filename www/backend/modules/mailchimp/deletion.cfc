component output="false" {
    // MailChimp in config/db/dev/create-modules.sql is demonstration metadata only.
    // This shipped placeholder has no sync implementation, customer-specific tables,
    // files or external resources. Core deletion removes its bookings.
    // Implement idempotent cleanup here before adding a real MailChimp integration.
    public struct function deleteCustomer(required numeric customerID) {
        return {success: true};
    }
}
