component output="false" {
    // This shipped scaffold has no customer-specific data. Extend this hook with the
    // actual module/project cleanup before adding customer tables, files or services.
    // It also runs for former subscribers and must be safe after a partial failure.
    public struct function deleteCustomer(required numeric customerID) {
        return {success: true};
    }
}
