using TestingProject.Infrastructure.Models;

namespace TestingProject.Infrastructure;

public interface ICustomerRepository
{
    Task<Customer> InsertCustomerAsync(Customer customer);
    Task<List<Customer>> GetAllCustomersAsync();
}