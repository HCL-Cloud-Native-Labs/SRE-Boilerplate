using FluentAssertions;
using System.Net;
using Xunit;
using github_docker_deploy.Controllers;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using github_docker_deploy;
using System.Threading.Tasks;

namespace github_docker_deploy_test
{
    public class DataControllerTest
    {
        public DataController _dataController;
        public DataControllerTest()
        {
            _dataController = new DataController();
        }
      
        [Fact]
        public async Task Test_GetAsync()
        {
            // Act
            var okResult = _dataController.Get().Result as OkObjectResult;

            // Assert
            var items = okResult.Value as IEnumerable<WeatherForecast>;
            items.Should().NotBeNull();
            okResult.StatusCode.Should().Be((int)HttpStatusCode.OK);
        
        }

        [Fact]
        public async Task Test_PostAsync()
        {
            var okResult = _dataController.Post(new DataControllerRequest(1,2)).Result as OkObjectResult;
            okResult.StatusCode.Should().Be((int)HttpStatusCode.OK);
            okResult.Value.Should().Be(3);
       
        }
    }
}
