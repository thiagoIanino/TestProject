using Microsoft.EntityFrameworkCore;
using TestingProject.Infrastructure.DbContext;
using TestingProject.Infrastructure.Models;

namespace TestingProject.Api.Seed;

public static class CustomerSeed
{
    public static void InitializeSeed(this WebApplication app)
    {
        
        using (var scope = app.Services.CreateScope())
        {
            var services = scope.ServiceProvider;

            try
            {
                InjectSeed(services);
            }
            catch (Exception ex)
            {
                var logger = services.GetRequiredService<ILogger<Program>>();
                logger.LogError(ex, "Ocorreu um erro ao seeding o banco de dados.");
            }
        }
    }

    private static void InjectSeed(IServiceProvider serviceProvider)
    {
        using (var context = new CustomerDbContext(
                   serviceProvider.GetRequiredService<DbContextOptions<CustomerDbContext>>()))
        {
            var test = context.Customers.ToList();
            // Verifica se há algum cliente no banco de dados.
            if (context.Customers.Any())
            {
                return;   // DB já foi seeded
            }

            context.Customers.AddRange(
                new Customer
                {
                    Name = "John Doe",
                    Age = 30
                },
                new Customer
                {
                    Name = "Jane Smith",
                    Age = 25
                }
            );

            context.SaveChanges();
        }
    }
}
