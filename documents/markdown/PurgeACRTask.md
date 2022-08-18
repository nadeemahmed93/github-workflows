### Table of Contents
- [Workflow](#workflow)
- [ACR PURGE](#acr-purge)
- [ACR Task View](#acr-task-view)


***


### Workflow
This workflow creates a scheduled task to delete tagged and untagged images from the non-prod Azure Container Registry using a cron scheduler.
### ACR PURGE
When you use an Azure Container Registry as part of a development workflow, the registry can quickly fill up with images and other artifacts that aren't needed after they're used for development.


**Scheduling a task:**
Trigger with cron expression - The timer trigger for a task uses a cron expression. The expression is a string with five fields specifying the minute, hour, day, month, and day of week to trigger the task.


**Create a task with a timer trigger:**
When you create a task with the az acr task create command, you can optionally add a timer trigger. Add the --schedule parameter and pass a cron expression for the timer.


     * * * * * 
     - - - - - 
     | | | | | 
     | | | | +---day of week(0 - 6)(Sunday = 0) 
     | | | +-----month(1 - 12) 
     | | +-------day of month(1 - 31) 
     | +---------hour(0 - 23) 
     +-----------min(0 - 59) 
     
The images which are older than 60 days will be deleted, and this workflow will create a Task with name "purgetask" and it schedules on every Sunday 2’o clock by using cronjob.


Cron Job "0 2 * * 0" 1st element stands for minutes (0-59), 2nd element stands for hour (0-23), 3rd  element stands for day(month) (1-31), 4th  element stands for month (1-12), 5th  element stands for day(week) (0-6)


    - name: Purge Running
       run: |
         az account set --subscription ${​​​​​​​{​​​​​​​ env.SUBSCRIPTION_ID }​​​​​​​}​​​​​​​
         az acr task create --name purgetask --cmd  "${​​​​​​​{​​​​​​​ env.PURGE_CMD }​​​​​​​}​​​​​​​" --schedule "0 2 * * 0" --registry ${​​​​​​​{​​​​​​​ env.REGISTRY_NAME }​​​​​​​}​​​​​​​ --context /dev/null 


On opening the Workflow, you will see the jobs which we have specified in the workflow yaml file and the steps as shown in the right side of the image.


***
         
### ACR Task View
Run the "az acr task show" command to see that the timer trigger is configured. By default, the base image update trigger is also enabled. This job helps to view the created task in table format form the console.


    - name: Display the Task in Table format
      run:  az acr task show --name purgetask --registry ${​​​​​​​{​​​​​​​ env.REGISTRY_NAME }​​​​​​​}​​​​​​​ --output table
       
***
 












