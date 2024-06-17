using Microsoft.EntityFrameworkCore;
using TestingProject.Api.Models;
using TestingProject.Infrastructure;
using TestingProject.Infrastructure.DbContext;
using TestingProject.Infrastructure.Models;
using TestingProject.Api.Seed;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<CustomerDbContext>(options =>
    options.UseMySql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        new MySqlServerVersion(new Version(8, 0, 23))));
// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<ICustomerRepository, CustomerRepository>();

var app = builder.Build();

app.InitializeSeed();

// Configure the HTTP request pipeline.
Console.WriteLine(app.Environment.IsDevelopment());
app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.MapGet("/customers", async (ICustomerRepository customerRepository) =>
    {
        var customers = await customerRepository.GetAllCustomersAsync();
        return Results.Ok(customers);
    })
    .WithName("GetCustomers")
    .WithOpenApi();

app.MapPost("/customers", async (CustomerCreateRequest request, ICustomerRepository customerRepository) =>
{
    var customer =
        await customerRepository.InsertCustomerAsync(new Customer { Age = request.Age, Name = request.Name });
    return Results.Created($"/customers/{customer.Id}", customer);
});

app.Run();