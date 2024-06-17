using Microsoft.EntityFrameworkCore;
using TestingProject.Infrastructure.DbContext;
using TestingProject.Infrastructure.Models;

namespace TestingProject.Infrastructure;

public class CustomerRepository : ICustomerRepository
{
    private readonly CustomerDbContext _dbContext;

    public CustomerRepository(CustomerDbContext dbContext)
    {
        _dbContext = dbContext;
    }
    
    public async Task<Customer> InsertCustomerAsync(Customer customer)
    {
        if (customer == null)
            throw new ArgumentNullException(nameof(customer));

        await _dbContext.Customers.AddAsync(customer);
        await _dbContext.SaveChangesAsync();
        return customer;
    }
    
    public async Task<List<Customer>> GetAllCustomersAsync()
    {
        return await _dbContext.Customers.ToListAsync();
    }
}