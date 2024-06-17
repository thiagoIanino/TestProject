using Microsoft.EntityFrameworkCore;
using TestingProject.Infrastructure.Models;

namespace TestingProject.Infrastructure.DbContext;

public class CustomerDbContext : Microsoft.EntityFrameworkCore.DbContext
{
    public DbSet<Customer> Customers { get; set; }

    public CustomerDbContext(DbContextOptions<CustomerDbContext> options) : base(options)
    {
    }
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Customer>()
            .Property(c => c.Id)
            .ValueGeneratedOnAdd();

    }
}